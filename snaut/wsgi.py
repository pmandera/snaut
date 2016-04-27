#!/usr/bin/env python
# -*- coding: utf-8 -*-

from ConfigParser import SafeConfigParser

from snaut import app_factory

conf = SafeConfigParser()

conf.read(['config.ini', 'config_local.ini'])

app = app_factory(conf)
