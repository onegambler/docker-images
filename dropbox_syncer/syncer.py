#!/usr/bin/env python

import logging
import os
import sys
from logging.config import fileConfig

import dropbox
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.triggers.cron import CronTrigger
from dropbox.exceptions import AuthError
from dropbox.files import FileMetadata, FolderMetadata, DeleteArg, WriteMode
from pathspec import PathSpec
from pathspec.patterns import GitWildMatchPattern

from hasher import DropboxContentHasher

dbx = dropbox.Dropbox(os.environ['DROPBOX_KEY'])
SYNC_DIR = "/data"

to_exclude_env_value = os.environ.get('TO_EXCLUDE')
TO_EXCLUDE = [] if not to_exclude_env_value else to_exclude_env_value.split(',')

configFile = os.path.join(os.path.dirname(__file__), 'logging_config.ini')
fileConfig(configFile)
logger = logging.getLogger(__name__)

spec = PathSpec.from_lines(GitWildMatchPattern, TO_EXCLUDE)

# Check that the access token is valid
try:
    dbx.users_get_current_account()
except AuthError as err:
    sys.exit("ERROR: Invalid access token; try re-generating an access token from the app console on the web.")


def _get_content_hash(path):
    hasher = DropboxContentHasher()
    with open(path, 'rb') as f:
        while True:
            chunk = f.read(1024)
            if len(chunk) == 0:
                break
            hasher.update(chunk)
    return hasher.hexdigest()


def _upload_file(file_path):
    with open(os.path.join(SYNC_DIR, file_path), 'rb') as file:
        dbx.files_upload(file.read(), _get_dropbox_path(file_path), mode=WriteMode.overwrite)


def _get_dropbox_path(original_path):
    if not original_path:
        return ''
    return '/' + original_path.replace('\\', '/')


def scan_folder(path=""):
    local_files = []
    local_folders = []
    logger.debug('Scanning {root}'.format(root=os.path.join(SYNC_DIR, path)))
    # getting all files and folders in local
    for entry in os.listdir(os.path.join(SYNC_DIR, path)):
        entry_path = os.path.join(SYNC_DIR, path, entry)
        if not spec.match_file(entry_path):
            if os.path.isfile(entry_path):
                local_files.append(os.path.join(path, entry))
            if os.path.isdir(entry_path):
                local_folders.append(os.path.join(path, entry))
    dropbox_files = []
    dropbox_folders = []

    # getting all files and folders in dropbox
    for entry in dbx.files_list_folder(_get_dropbox_path(path)).entries:
        if isinstance(entry, FileMetadata):
            dropbox_files.append(entry)
        if isinstance(entry, FolderMetadata):
            dropbox_folders.append(entry)

    logger.debug('\tFound the following local files [{list}]'.format(list=', '.join(local_files)))
    logger.debug('\tFound the following local folders [{list}]'.format(list=', '.join(local_folders)))

    files_to_delete = [file for file in dropbox_files if file.path_display[1:] not in local_files]
    folders_to_delete = [folder for folder in dropbox_folders if folder.path_display[1:] not in local_folders]

    if logger.isEnabledFor(level=logging.DEBUG):
        logger.debug('\t\tThe following folders will be deleted [{list}]'
                     .format(list=', '.join([folder.path_display for folder in folders_to_delete])))
        logger.debug('\t\tThe following files will be deleted [{list}]'
                     .format(list=', '.join([file.path_display for file in files_to_delete])))

    dbx.files_delete_batch([DeleteArg(to_delete.path_lower) for to_delete in files_to_delete + folders_to_delete])
    for file in local_files:
        match = next(
            (
                dropbox_file
                for dropbox_file in dropbox_files if _get_dropbox_path(file) == dropbox_file.path_display
            ), None)
        if match:
            local_file_hash = _get_content_hash(os.path.join(SYNC_DIR, file))
            if local_file_hash != match.content_hash:
                logger.debug('\t\tFile \'{file}\' exists but hashes don\'t match. Overriding'.format(file=file))
                _upload_file(file)
            else:
                logger.debug('\t\tFile \'{file}\' exists and is up to date, skipping'.format(file=file))
        else:
            logger.debug('\t\tNew file \'{file}\'. Uploading'.format(file=file))
            _upload_file(file)
    for folder in local_folders:
        if not any(dropbox_folder for dropbox_folder in dropbox_folders if folder == dropbox_folder.path_display[1:]):
            dbx.files_create_folder_v2(_get_dropbox_path(folder))
            logger.debug('\t\tCreated folder {folder}'.format(folder=folder))
        scan_folder(folder)


if __name__ == '__main__':

    cron_schedule = os.environ.get('CRON_SCHEDULE', '0 2 * * *')
    scheduler = BlockingScheduler()
    scheduler.add_job(scan_folder, CronTrigger.from_crontab(cron_schedule))
    print('Press Ctrl+{0} to exit'.format('Break' if os.name == 'nt' else 'C'))

    try:
        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        pass
