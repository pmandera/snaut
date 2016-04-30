from ConfigParser import RawConfigParser
import snaut.snaut as snaut
import unittest
import json
import csv
import StringIO

from example_space import example_semspace


class SnautTestCase(unittest.TestCase):
    def setUp(self):
        conf = RawConfigParser()

        conf.add_section('semantic_space')
        conf.set('semantic_space', 'semspaces_dir', './data')
        conf.set('semantic_space', 'preload_space', 'no')
        conf.set('semantic_space', 'prenormalize', 'no')
        conf.set('semantic_space', 'numpy_dtype', 'float64')
        conf.set('semantic_space', 'matrix_size_limit', '-1')
        conf.set('semantic_space', 'allow_space_change', 'no')

        conf.add_section('server')
        conf.set('server', 'doc_dir', './doc')
        conf.set('server', 'static_dir', './snaut/templates')
        conf.set('server', 'template_dir', './snaut/static')
        conf.set('server', 'log_name', 'snaut')
        conf.set('server', 'log_file', '')
        conf.set('server', 'log_level', 'critical')
        conf.set('server', 'template_dir', './snaut/static')
        conf.set('server', 'root_prefix', '')

        self.app = snaut.app_factory(conf, example_semspace).test_client()

    def tearDown(self):
        pass

    def test_status(self):
        response = self.app.get('/status', follow_redirects=True)
        status = json.loads(response.data)
        assert status['semspaceLoaded'] is True
        assert status['semspaceTitle'] == 'Random semantic space'
        assert status['semspaceDesc'] == 'Demo semantic space description.'

    def test_similar_words1(self):
        data = {'words1': ['first', 'fifth', 'twelfth'], 'metric': 'cosine'}
        data_json = json.dumps(data)
        response = self.app.post('/similar/', data=data_json,
                                 follow_redirects=True,
                                 content_type='application/json')
        print response

        result = json.loads(response.data)
        print result

        assert result['notDefined']['words1'] == ['twelfth']
        assert result['notDefined']['words2'] is None

        sims = result['similarities']
        for w, nns in sims.iteritems():
            assert nns[0][0] == w
            assert len(nns) == 10

    def test_similar_words1_words2(self):
        data = {'words1': ['first', 'fifth', 'twelfth'], 'words2': ['third',
                'second', 'fifth', 'thirteenth'], 'metric': 'cosine'}
        data_json = json.dumps(data)
        response = self.app.post('/similar/', data=data_json,
                                 follow_redirects=True,
                                 content_type='application/json')

        print response
        result = json.loads(response.data)

        print result
        assert result['notDefined']['words1'] == ['twelfth']
        assert result['notDefined']['words2'] == ['thirteenth']

        sims = result['similarities']
        for w, nns in sims.iteritems():
            assert len(nns) == 3

    def test_similarity_matrix_words1(self):
        data = {'words1': ['first', 'fifth', 'twelfth'], 'metric': 'cosine'}
        data_json = json.dumps(data)
        response = self.app.post('/similarity-matrix/',
                                 data=dict(data=data_json),
                                 follow_redirects=True)

        content_disposition = response.headers["Content-Disposition"]
        assert content_disposition == "attachment; filename=similarities.csv"

        f = StringIO.StringIO(response.data)
        reader = list(csv.reader(f, delimiter=','))

        cols = reader[0][1:]
        assert cols == ['first', 'fifth']

        rows = [r[0] for r in reader[1:]]
        assert rows == example_semspace.words

        for row in reader[1:]:
            row_word = row[0]
            row_distances = zip(cols, row[1:])
            for col_word, dist in row_distances:
                pair_dist = example_semspace.pair_distance(row_word, col_word)
                print col_word, row_word, float(dist), pair_dist
                assert float(dist) - pair_dist < 10e-10

    def test_similarity_matrix_words1_words2(self):
        data = {'words1': ['first', 'fifth', 'twelfth'], 'words2': ['third',
                'second', 'fifth', 'thirteenth'], 'metric': 'cosine'}
        data_json = json.dumps(data)
        response = self.app.post('/similarity-matrix/',
                                 data=dict(data=data_json),
                                 follow_redirects=True)

        content_disposition = response.headers["Content-Disposition"]
        assert content_disposition == "attachment; filename=similarities.csv"

        f = StringIO.StringIO(response.data)
        reader = list(csv.reader(f, delimiter=','))

        cols = reader[0][1:]
        assert cols == ['first', 'fifth']

        rows = [r[0] for r in reader[1:]]
        assert rows == ['third', 'second', 'fifth']

        for row in reader[1:]:
            row_word = row[0]
            row_distances = zip(cols, row[1:])
            for col_word, dist in row_distances:
                pair_dist = example_semspace.pair_distance(row_word, col_word)
                print col_word, row_word, float(dist), pair_dist
                assert float(dist) - pair_dist < 10e-10

    def test_pairs(self):
        data = {'wordPairs': [
            [['first'], ['second']],
            [['fifth'], ['sixth']],
            [['twelfth'], ['eleventh']]],
            'metric': 'cosine'}
        data_json = json.dumps(data)
        print data_json
        response = self.app.post('/pairs/', data=dict(data=data_json),
                                 follow_redirects=True)

        content_disposition = response.headers["Content-Disposition"]
        assert content_disposition == "attachment; filename=word-pairs.csv"

        f = StringIO.StringIO(response.data)
        reader = list(csv.reader(f, delimiter=','))

        cols = reader[0]
        print reader
        assert cols == ['word_1', 'word_2', 'distance']

        for w1, w2, dist in reader[1:]:
            pair_dist = example_semspace.pair_distance(w1, w2)
            print w1, w2, float(dist), pair_dist
            assert float(dist) - pair_dist < 10e-10


if __name__ == '__main__':
    unittest.main()
