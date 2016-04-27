# Overview

*snaut* allows to measure distance between words or documents and explore
distributional semantics models through a convenient interface. It was created
primarily as a tool for psycholinguists that can be used to measure
similarities between words.

# Getting started

After installing and starting *snaut* and you can start working with the
semantic spaces by opening your Web browser and going to
[http://localhost:5005](http://localhost:5005).

The first thing you need to do is to load a semantic space which you want to
use. If there is no space loaded at the moment, a window listing available
semantic spaces (the ones you put in the `data` folder) should appear
automatically. You should select the semantic space from the dropdown menu and
click at the `Load` button.

When the space is loaded, its name will apprear in the left upper corner of the
screen. At this point, you can start working with the semantic space.

The interface is organized into four menus - each allows to explore the
semantic space in a different way.  You can read more about these menus
[here](#menus). The simplest way in which you can start working with the
semantic space is to pick a few words or phrases and type them in the form in
the `Neighbours` tab (each word/phrase in a separate line; words in the phrase
separated by space) and click on the `Calculate` button. You should see small
tables showing words that are most similar to the words or phrases you typed in
according to the semantic space.

# Loading spaces <a name="loading"></a>

To add more spaces to the menu you need to drop a semantic space file in the
`data` folder. It will then appear in the space loading menu. If you are unsure
about where you should drop the files you can click on the `Change` button and
the target folder path will be displayed along with other information. You can
customize location of the spaces by changing the `semantic_spaces` setting in
the configuration file (see [here](#configuration) for more details).

# Words and phrases

The interface allows to work with single words or with phrases composed of
multiple words. In fact you can even think about a whole document as a very
long phrese. If you enter a multi-word phrase to the input field it will be
represented by the model as a sum of the vectors of all its words. If any of the
words used in the phrase is not present in the loaded semantic space, *snaut*
will not be able to compute the vector for this phrase and, as the result, it
will ignore the whole phrase.

The phrases need to be entered as a list of words separated with spaces
(interpuction must be removed).

# Menus <a name="menus"></a>

### Neighbours <a name="explore-menu"></a>

This menu allows to look up nearest neighbours of a set of words.
For example, in order to check what are the words with a smallest distance to
*brain* and *dinosaur*, type in `brain` and `dinosaur` into the input box on
separate lines and press `Calculate`. You can choose the metric that is used to
compute distance in the space.

You can also try to enter phrases composed of multiple words, for instance
compare `behavior`, `research` and `behavior research`.

### Matrix <a name="matrix-menu"></a>

If you need to obtain measurements for a large number of words, you can use the
matrix menu.

The words for which you need the scores should be entered in the input form on
the left. Each word or phrase should be entered in a separate line. Next, in the
dropdown menu you can choose what kind of comparison do you want to make. The
available options are:

* distances between all pairs of words in the list
* distances between the words in the list and all other words in the loaded
semantic space
* distances between all pairs of words between the left input field and the
right input field

When you click on `Calculate`, *snaut* will compute the scores and, after this
is finished, it will initialize download of a file with the results. The file
is in a CSV format: it contains a table in a plain text with columns separated
with commas.

You can read in the list of words to the text field from a file on your disc by
clicking on the `Load from a file` button below the target input field. The
`Check availability` button can be used check whether all words specified in
the input field are present in the semantic space. Keep in mind that, if some
of the words are not in the space, *snaut* will ignore them when computing the
semantic distance measures.

### Pairwise <a name="pairwise-menu"></a>

You can use this menu to investigate distances between individual pairs of
words/documents. Each pair should be entered on a separate row in the input
field and elements of the pair should be speparated with a colon (':') . After
clicking on the `Calculate` button, *snaut* will do the calculation and a
download of a CSV file with the result will be initialized.

For instance, in order to calculate the distance between pairs of words: `home`
and `window`, `car` and `wheel`, `fast car` and `slow car`. You should enter:

```
home : window
car : wheel
car : cloud
fast car : slow car
```

Similarily to the Matrix interface you can load the list of pairs from a text
file or check the availability of the words in the semantic space.

### Analogy <a name="analogy-menu"></a>

*snaut* implements an offset method described by Mikolov, Yih, & Zweig (2013).
The analogy interface allows you to perform algebraic operations using vector
semantic space and capture some regularities in the language.

The classical example involves the computation  *king* - *man* + *woman* which
results in a vector very close to *queen*.

The computation can be performed by entering the words vectors of which you
want to have positive or negative contribution in the calculation. For
instance, in order to calculate *king* - *man* + *woman* you need to enter
`king, woman` in the field *positive vectors* and `man` in the field *negative
vectors*.

# Configuration

*snaut* comes with a set of options that should work well for most usecases
running on a local computer. Nevertheless, you may want to tweak some of the
available options. This can be done by adjusting the settings in `config.ini`,
which resides in the *snaut* main folder.

The configuration file is divided in two sections: `server` and
`semantic_space`. The `server` section has two options:

* `host` - this allows to specify on which IP address *snaut* is supposed to
listen for requests. Two useful values are `127.0.0.1` (default; listen only
for requests coming from the local machine) and `0.0.0.0` (listen for
requests from any IP address; if set anyone will be able to communicate with
the interface running on this computer)
* `port` - port on which *snaut* will listen

The `semantic_space` allows to configure settings directly related to how
*snaut* handles the semantic spaces, using the following options:

* `semspaces_dir` - a directory in which available semantic spaces are located (
default `./data/`)
* `preload_space` - if `yes` load a semantic space on startup (default: `yes`)
* `preload_space_file` - if `preload_space` is set to `yes` the space in this path will be preloaded (default: xxx)
* `preload_space_format` - the format of the space that will be preloaded
* `prenormalize` - when loading a space normalize all vectors to have length 1. This speeds up computation of cosine distances but does not allow to compute the other metrics (default: `no`)
* `matrix_size_limit` - a limit on the size of the computation that can be performed using *snaut*, in general this setting specifies the number of distance value which can be computed in each request, if set to -1 no limit will be enforced
(default: `-1`)
* `allow_space_change` - if set to `yes`allow the user to change the loaded semantic space using the web interface (using the `Change` button in the semantic space menu), if `no` snaut only the preloaded space can be used (default: `yes`)

# Usage as a Web-server

Although the default mode of using *snaut* is local, one-user only, it can be
also run on a server to allow other people access the semantic space over a
network. You need to keep in mind that computing semantic distances often
involves performing operations over large matrices and can be computationally
expensive: you need to make sure that you want to allow external users to make
such extensive use of your computational resources.

Nevertheless, if your semantic space has relatively small number of words and
not too many dimensions, *snaut* may provide you with an extremly convenient
way to share your semantic space with the world.

Even if you work with very large space you may consider launching *snaut* on a
server or a workstation machine and then share it internally in your research
group.

If you intend to expose the space in the server mode you will need to make
some adjustments in the `config.ini` file.

First of all, you will need to tell *snaut* to respond to requests coming from
computers other than the local machine. In order to do that set `host` value to
`0.0.0.0`.

If you want to make the space publicly available, you probably want to impose
some constraints on what the external users can do. If you do not want to allow
changing of the loaded semantic spaces through the web interface, you need to
set the `allow_space_change` to `no` and select the space that should be loaded
when the  *snaut*  receives first request by setting `preload_space` to `yes`
and `preload_space_file` and `preload_space_format`.

You probably also do not want your users to be able to compute huge matrices
including billions of cells. In order to prevent the users from doing that set
the `matrix_size_limit` to a reasonable value (in our experience values like
1,000,000 work pretty well).

An additional optimization that you should consider is setting `prenormalize`
to `yes`. This can lead to large speed-ups in computing cosine similarities, so
I would strongly recommend setting this option in most cases, since other
metrics are rarelly of interst for most users.

Currently snaut does not allow to password protect the interface. It is
relatively easy to do using reverse proxy setup e.g. with
[nginx](http://nginx.com/resources/admin-guide/reverse-proxy/) or
[Apache](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html).

# File formats

## CSV

snaut works with CSV and [Matrix Market](http://math.nist.gov/MatrixMarket/)
file formats.

Values in the CSV file should be separated by spaces and contain words in the
first column and vector values in the following columns.  *snaut* treats lines
starting with '#' as comments. Optionally, you can provide additional
information about the space in the comments opening the file:

* If the first line contains a comment starting with 'TITLE: ', *snaut* treat
it as a title of the space, that will be displayed in the status field of the
interface.
* The following lines are treated as the description of the space and will be
visible after clicking on `More info` 

If the first uncommented line contains two integer values, it will be treated
as an information about the number of rows and columns in the file.

If the filename ends with `*.gz`, *snaut* will assume that the file is
compressed using gzip.

## Semantic space market

In the case of semantic spaces which contain a large number of 0.0 values, such
as those created when counting word co-occurrences without a dimensionality
reduction step, the CSV format is not practical.  For such cases it is better
to use the Matrix Market format which handles sparse matrices more efficiently.
For more details see [here](http://math.nist.gov/MatrixMarket/)

The space based on the Matrix Market format consist of the following files:

* data.mtx - matrix with word vectors as rows
* row-labels - a text with one word on a line, in an order corresponding to
row vectors in the data.mtx file

Optionally, you can provide a README.md file which contains a title of the
space in the first line and a description in the following lines. The title
should be separated from the description with one blank line.

The files should be included in one folder or zipped in one file to which you
need to point *snaut*.
