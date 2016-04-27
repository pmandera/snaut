# Overview

*snaut* allows to measure distance between words or documents and explore
distributional semantics models through a convenient interface. It was created
primarily as a tool for psycholinguists that can be used to measure
similarities between words.

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
