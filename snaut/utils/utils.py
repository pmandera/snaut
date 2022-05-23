#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import logging
from logging.handlers import RotatingFileHandler

import io as StringIO


def df_to_csv_string(df):
    """Converts pandas DataFrame to a CSV string."""
    out = StringIO.StringIO()
    df.to_csv(out, encoding='utf-8')
    return out.getvalue()


def get_logger(log_name, log_file, log_level):
    """
    Get a logger.

    If log_dest is set to 'gunicorn.error' use gunicorn error logger. Otherwise,
    create a new logger with log_dest and use log_dest as ther path for the log
    file.
    """

    LEVELS = {
        'debug': logging.DEBUG,
        'info': logging.INFO,
        'warning': logging.WARNING,
        'error': logging.ERROR,
        'critical': logging.CRITICAL}

    level = LEVELS[log_level]

    logger = logging.getLogger(log_name)
    logger.setLevel(level)

    if log_file:
        handler = RotatingFileHandler(os.path.abspath(log_file),
                                      maxBytes=10000, backupCount=1)
        handler.setLevel(level)

        formatter = logging.Formatter(
            '%(asctime)s [%(levelname)s] %(message)s')

        handler.setFormatter(formatter)

        logger.addHandler(handler)

    return logger
