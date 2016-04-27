#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
This is the flask server that provides a web interface to the semspaces module.
"""

import os
import sys

from ConfigParser import SafeConfigParser

import markdown
import json
import unicodecsv as csv
import cStringIO as StringIO

from flask import Flask, jsonify, request, make_response
from flask import Markup, render_template

from utils.utils import df_to_csv_string
from semspaces.space import SemanticSpace


# The global semspace object representing the loaded semantic space is necessary
# to make it possible to reload the semantic space when running as a local
# instance.
#
# When running as a server the 'allow_space_change' setting in the configuration
# file should be set to 'no' and 'preload_space'  should be set to 'yes' so that
# a semspace is loaded when starting the server and never changes later.
#
semspace = None


def app_factory(conf, init_semspace=None):
    """Return the flask app based on the configuration."""

    root_prefix = conf.get('server', 'root_prefix')
    doc_dir = conf.get('server', 'doc_dir')

    semspaces_dir = conf.get('semantic_space', 'semspaces_dir')
    prenormalize = conf.getboolean('semantic_space', 'prenormalize')
    matrix_size_limit = conf.getint('semantic_space', 'matrix_size_limit')
    numpy_dtype = conf.get('semantic_space', 'numpy_dtype')
    allow_space_change = conf.getboolean('semantic_space', 'allow_space_change')

    preload_space = conf.getboolean('semantic_space', 'preload_space')

    static_url = "%s/static" % root_prefix
    app = Flask(__name__, static_url_path=static_url)

    def load_semspace(semspace_path, semspace_format='semspace'):
        """Load a semantic space based on the path and format."""

        global semspace

        if semspace_format == 'ssmarket':
            semspace = SemanticSpace.from_ssmarket(semspace_path,
                                                   prenorm=prenormalize)
            return True
        elif semspace_format == 'csv':
            semspace = SemanticSpace.from_csv(semspace_path,
                                              prenorm=prenormalize,
                                              dtype=numpy_dtype)
            return True
        else:
            raise Exception("Space format '%s' unknown!" % semspace_format)

    def check_space_preload():
        """Check if semantic space should be preloaded."""

        if preload_space:
            semspace_path = conf.get('semantic_space', 'preload_space_file')
            semspace_format = conf.get('semantic_space', 'preload_space_format')

            print 'Pre-loading semantic space: %s' % semspace_path
            load_semspace(semspace_path, semspace_format)
            print 'Semantic space loaded.'

            return True
        else:
            return False

    if not check_space_preload() and init_semspace:
        global semspace
        semspace = init_semspace

    def available_spaces():
        """List spaces available in the directory."""

        spaces = []

        for top, dirs, files in os.walk(semspaces_dir):
            for fname in files:
                spaces.append(os.path.join(top, fname))

        return spaces

    def split_by_defined(words):
        """Split a list of words based on whether they are in the space."""

        defined = []
        undefined = []

        for w in words:
            if semspace.defined_at(w):
                defined.append(w)
            else:
                undefined.append(w)

        return defined, undefined

    def check_matrix_size(semspace, words1, words2=None):
        """
        Verify if the size of the requested data matrix.

        Return True if the size does not exceed the size limit specified
        in the configuration file.
        """

        if matrix_size_limit == -1:
            return True
        elif words1 and words2:
            if len(words1) * len(words2) <= matrix_size_limit:
                return True
            else:
                return False
        else:
            if len(words1) * semspace.shape[0] <= matrix_size_limit:
                return True
            else:
                return False

    # Application routes and controllers

    @app.route('%s/' % root_prefix)
    def root():
        """Serve index page."""

        static_prefix = static_url
        url_prefix = root_prefix
        api_prefix = root_prefix

        return render_template('index.html', **locals())

    @app.route('%s/list-semspaces/' % root_prefix)
    def req_semspaces_list():
        """Return a list of available semantic spaces.

        Returns json with:

        * paths - directory including the semantic spaces
        * availableSpaces - array listing available spaces
        """

        if not allow_space_change:
            return make_response('Not allowed!'), 403

        data = {'paths': semspaces_dir, 'availableSpaces': available_spaces()}

        return jsonify(data)

    @app.route('%s/load-semspace/' % root_prefix, methods=['POST'])
    def req_load_space():
        """Load another semantic space.

        Takes a json with:

        * semspacePath - path to a semantic space
        * semspaceFormat - format of a semantic space
        """

        if not allow_space_change:
            return make_response('Not allowed!'), 403

        data = request.get_json()
        path = data['semspacePath']
        space_format = data['semspaceFormat']

        # TODO improve this
        if load_semspace(path, space_format):
            return make_response("ok")
        else:
            return make_response("error")

    @app.route('%s/status/' % root_prefix)
    def status():
        """Return server status.

        Returns json with:

        * semspaceLoaded - true if any semantic space is loaded
                            false otherwise
        * semspaceTitle - title of the loaded semantic space
        * semspaceDesc - description of the loaded semantic space
        * allowChange - true if the app would allow to change the loaded space
                            false otherwise
        * allowedMetrics - a list of the metrics that can be computed
        """

        if semspace is None:
            check_space_preload()

        status_dict = {}
        status_dict['semspaceLoaded'] = semspace is not None

        if semspace:
            status_dict['semspaceTitle'] = semspace.title
            status_dict['semspaceDesc'] = semspace.readme
            status_dict['allowChange'] = allow_space_change
            status_dict['allowedMetrics'] = semspace.allowed_metrics()

        return jsonify(status_dict)

    @app.route('%s/similar/' % root_prefix, methods=['POST'])
    def similar():
        """Return most similar words.

        Takes a json with the following fields:

        * words1 - reference list of words
        * metric - metric which should be used when calculating
                    distances
        * n (optional; default: 10) - number of neighbours to be
                    returned
        * words2 (optional) - words which can be included in the
                    result, if not given all words in the space will be used

        Returns json with:

        * similarities - dictionary with reference words as keys and
            list of neighbours with their distances as values
        * notDefined:
            words1 - words in words1 that are not defined in the space
            words2 - words in words2 that are not defined in the space
        """

        data = request.get_json()

        metric = data['metric']
        n = data.get('n', 10)
        words_1 = data['words1']

        (words_1_ok, words_1_nd) = split_by_defined(words_1)

        if 'words2' not in data:
            words_2_nd = None
            most_similar = semspace.most_similar(words_1_ok,
                                                 n=n, metric=metric)
        else:
            words_2 = data['words2']
            (words_2_ok, words_2_nd) = split_by_defined(words_2)
            most_similar = semspace.most_similar(words_1_ok, words_2_ok,
                                                 n=n, metric=metric)

        result = {'similarities': most_similar,
                  'notDefined': {'words1': words_1_nd, 'words2': words_2_nd}}

        return jsonify(result)

    @app.route('%s/similarity-matrix/' % root_prefix, methods=['POST'])
    def similarity_matrix():
        """Return similarity matrix (in csv).

        Expects a json with the following fields:

        * words1 - reference list of words
        * metric - metric which should be used when calculating
                    distances
        * words2 (optional) - words which can be included in the
                    result, if not given all words in the space will be used

        Return csv, comma separated matrix.
        """
        data = json.loads(request.form['data'])
        metric = data['metric']
        words_1 = data['words1']
        if 'words2' not in data:
            if check_matrix_size(semspace, words_1):
                (words_1_ok, words_1_nd) = split_by_defined(words_1)
                most_similar = semspace.all_distances(words_1_ok, metric=metric)
            else:
                return make_response("Matrix size error!")
        else:
            words_2 = data['words2']
            if check_matrix_size(semspace, words_1, words_2):
                (words_1_ok, words_1_nd) = split_by_defined(words_1)
                (words_2_ok, words_2_nd) = split_by_defined(words_2)
                most_similar = semspace.matrix_distances(words_1_ok, words_2_ok,
                                                         metric=metric)
            else:
                return make_response("Matrix size error!")

        most_similar_csv = df_to_csv_string(most_similar.T)
        response = make_response(most_similar_csv)
        response.headers["Content-Disposition"] = (
            "attachment; filename=similarities.csv")

        return response

    @app.route('%s/offset/' % root_prefix, methods=['POST'])
    def offset():
        """
        Return n words colsest to a calculated vector.

        Current behavior of filtering out used words is consistent with the
        implementation in the word2vec tools. It should be considered if this
        should not be changed in the future versions.
        """

        data = request.get_json()

        positive = data['positive']
        negative = data['negative']
        metric = data['metric']
        n = data.get('n', 10)

        (positive_ok, positive_nd) = split_by_defined(positive)
        (negative_ok, negative_nd) = split_by_defined(negative)

        closest = semspace.offset(positive_ok, negative_ok,
                                  metric=metric, n=n, filter_used=True)

        result = {'closest': closest,
                  'notDefined': {'positive': positive_nd,
                                 'negative': negative_nd}}

        return jsonify(result)

    @app.route('%s/pairs/' % root_prefix, methods=['POST'])
    def pairs():
        """Return similarity matrix (in csv).

        Expects a json with the following fields:

        * wordPairs - array containing arrays with pairs of words
        * metric - metric which should be used when calculating
                    distances

        Return csv, comma separated matrix.
        """

        data = json.loads(request.form['data'])

        metric = data['metric']
        word_pairs = data['wordPairs']

        if matrix_size_limit > 0 and len(word_pairs) * 2 > matrix_size_limit:
            return make_response("Matrix size error!")

        s = StringIO.StringIO()

        writer = csv.writer(s)
        writer.writerow(['word_1', 'word_2', 'distance'])

        for w1, w2 in word_pairs:
            if semspace.defined_at(w1) & semspace.defined_at(w2):
                dist = semspace.pair_distance(w1, w2, metric)
                w1_label = ' '.join(w1)
                w2_label = ' '.join(w2)
                writer.writerow([w1_label, w2_label, dist])

        response = make_response(s.getvalue())
        response.headers["Content-Disposition"] = (
            "attachment; filename=word-pairs.csv")

        return response

    @app.route('%s/defined-at/' % root_prefix, methods=['POST'])
    def defined_at():
        """Return information about which of the listed words
        are defined in a semantic space.

        Takes a json array with list of words to check.

        Returns json with:

        * available - json array with list of words defined
        * notAvailable - json array with list of words that are undefined
        """

        data = request.get_json()

        if 'words' in data:
            (available, not_available) = split_by_defined(data['words'])
            response = jsonify({'available': available,
                                'notAvailable': not_available})
        else:
            response = jsonify({'error': 'No words listed!'})

        return response

    @app.route('%s/doc/<section>' % root_prefix)
    def help(section):
        """Return a markdown file from the doc directory rendered to html."""

        path = '%s/%s.md' % (doc_dir, section)
        doc_text = open(path).read()

        extentions = ['markdown.extensions.fenced_code',
                      'markdown.extensions.tables']

        processed = markdown.markdown(doc_text, extensions=extentions)
        content = Markup(processed)

        static_prefix = static_url
        url_prefix = root_prefix

        return render_template('help.html', **locals())

    return app

if __name__ == '__main__':

    conf = SafeConfigParser()

    if len(sys.argv) > 1:
        conf.read([sys.argv[1]])
    else:
        conf.read(['config.ini', 'config_local.ini'])

    server_host = conf.get('server_local', 'host')
    server_port = conf.getint('server_local', 'port')
    root_prefix = conf.get('server', 'root_prefix')

    url = 'http://localhost:%s/%s' % (server_port, root_prefix)

    browser_open = conf.getboolean('server_local', 'start_browser')

    if browser_open:
        welcome_msg = 'If the browser does not start automatically go to '
        import threading
        import webbrowser
        threading.Timer(3.0, lambda: webbrowser.open(url)).start()
    else:
        welcome_msg = 'Open your browser and go to'

    print '%s %s' % (welcome_msg, url)
    print 'Keep this window open.'
    print

    app = app_factory(conf)

    app.debug = conf.getboolean('server_local', 'debug')
    app.run(host=server_host, port=server_port)
