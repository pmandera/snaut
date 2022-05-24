#!/usr/bin/env python
# -*- coding: utf-8 -*-

from configparser import SafeConfigParser

from .snaut import app_factory

conf = SafeConfigParser()

conf.read(['config.ini', 'data/config.ini', 'config_local.ini'])

app = app_factory(conf)
