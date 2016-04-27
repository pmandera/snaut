#!/usr/bin/env python
# -*- coding: utf-8 -*-

import cStringIO as StringIO

def df_to_csv_string(df):
    """Converts pandas DataFrame to a CSV string."""
    out = StringIO.StringIO()
    df.to_csv(out, encoding='utf-8')
    return out.getvalue()
