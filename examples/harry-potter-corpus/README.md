# Creating a corpus for PrimeQA

This is a precursor to the article "How I built my first QA system with PrimeQA", in which it's described how to download a book series corpus and prepare it for indexing using any of PrimeQA retrievers. The steps are performed in a Linux CLI environment. 

## Download and preprocessing

The following steps have [Git](https://git-scm.com/), [Python 3](https://www.python.org/downloads/), and [Conda](https://docs.conda.io/en/latest/) as requirements. The example was tested with the Bash shell. 

We need to prepare the preprocessing environment. If you haven't done so while reading the main article, you can download the scripts from PrimeQA's `create-primeqa-app` project this way: 

```
workspace $ git clone git@github.com:primeqa/create-primeqa-app.git 
workspace $ cd create-primeqa-app 
create-primeqa-app $ cd examples/harry-potter-corpus/ 
harry-potter-corpus $ 
```

I recommend using an environment management system like [Miniconda](https://docs.conda.io/en/latest/miniconda.html). We can create and activate an environment with the following commands: 

```
harry-potter-corpus $ conda deactivate 
harry-potter-corpus $ conda create -n hp-corpus python=3.9 
(...) 
harry-potter-corpus $ conda activate hp-corpus 
(hp-corpus) harry-potter-corpus $ 
```

With this isolation mechanism, we can install some dependencies avoiding version conflicts with other environments. The `pre-requisites.sh` script installs [spaCy](https://spacy.io/) and the [Kaggle CLI tool](https://www.kaggle.com/docs/api):

```
(hp-corpus) harry-potter-corpus $ ./pre-requisites.sh 
(...) 
(hp-corpus) harry-potter-corpus $
```

## Download the corpus from Kaggle

We will use the [Harry Potter corpus from Kaggle](https://www.kaggle.com/datasets/balabaskar/harry-potter-books-corpora-part-1-7). It can be downloaded manually from the web page, or with the `kaggle` CLI tool if you have a registered user and API credentials. The token file can be downloaded by clicking the _Create New API Token_ in the _API_ section in the user's profile page [https://www.kaggle.com/USER/account](https://www.kaggle.com/USER/account), and the CLI tool is installed via pip by the `pre-requisites.sh` script described above.

`kaggle.json` file contents example: 

```
(hp-corpus) harry-potter-corpus $ cat kaggle.json 
{"username":"hernanrojek","key":"a28b184bf9c5d904e23fbcd6e51865ee"} 
(hp-corpus) harry-potter-corpus $ 
```

With a valid token file, we can download and extract the book series: 

```
(hp-corpus) harry-potter-corpus $ ./download-corpus.sh 
Downloading corpus from Kaggle... 
Downloading harry-potter-books-corpora-part-1-7.zip to /workspace/create-primeqa-app/examples/harry-potter-corpus 
100%|███████████████████████████| 2.43M/2.43M [00:00<00:00, 142MB/s] 
Extracting files... 
Archive:  harry-potter-books-corpora-part-1-7.zip 
  inflating: Book1.txt 
  inflating: Book2.txt 
  inflating: Book3.txt 
  inflating: Book4.txt 
  inflating: Book5.txt 
  inflating: Book6.txt 
  inflating: Book7.txt 
  inflating: characters_list.csv 
(hp-corpus) harry-potter-corpus $ 
```

If you downloaded it with a web browser, just unzip it:

```
(hp-corpus) harry-potter-corpus $ unzip ~/Downloads/archive.zip -d . 
Archive:  /home/youruser/Downloads/archive.zip 
  inflating: ./Book1.txt 
  inflating: ./Book2.txt 
  inflating: ./Book3.txt 
  inflating: ./Book4.txt 
  inflating: ./Book5.txt 
  inflating: ./Book6.txt 
  inflating: ./Book7.txt 
  inflating: ./characters_list.csv 
(hp-corpus) harry-potter-corpus $ 
```

## Inspection

Let's take a look at the material. 

At first glance, we see that the text is divided into paragraphs by blank lines, and the paragraphs themselves are divided into lines about ten words long.

```
(hp-corpus) harry-potter-corpus $ less -X Book1.txt 
 
THE BOY WHO LIVED 
 
Mr. and Mrs. Dursley, of number four, Privet Drive, 
were proud to say that they were perfectly normal, 
thank you very much. They were the last people you’d 
expect to be involved in anything strange or 
mysterious, because they just didn’t hold with such 
nonsense. 
 
Mr. Dursley was the director of a firm called 
Grunnings, which made drills. He was a big, beefy 
: 
```

We should consider the presence of page footers, inserted in many cases within paragraphs:

```
could bear it if anyone found out about the Potters. 
Mrs. Potter was Mrs. Dursley’s sister, but they hadn’t 
 
Page | 2 Harry Potter and the Philosophers Stone - J.K. Rowling 
 
 
met for several years; in fact, Mrs. Dursley pretended 
she didn’t have a sister, because her sister and her 
good-for-nothing husband were as unDursleyish as it 
was possible to be. The Dursleys shuddered to think 
what the neighbors would say if the Potters arrived in 
the street. The Dursleys knew that the Potters had a 
: 
```

And some artifacts that end up as garbled text. Fortunately, these appear only in footers:


```
(hp-corpus) harry-potter-corpus $ less -X Book5.txt 
Dolohov grinned. With his free hand, he pointed from 
the prophecy still clutched in Harry’s hand, to 
himself, then at Hermione. Though he could no longer 
 
Page | lOUHarry Potter and the Order of the Phoenix - J.K. Rowling 
 
 
speak his meaning could not have been clearer: Give 
me the prophecy, or you get the same as her... 
:
```

## Preparation 

We need to get the corpus into the right shape for the indexing process. PrimeQA's ColBERT IR engine [requires](https://github.com/primeqa/primeqa/tree/main/primeqa/ir#dense-index-with-colbert-engine) a collection of documents in a `tsv` file, in a tabular `id text title`  arrangement, ideally in the 1-180 word range. 

We want this collection of documents to retain as much continuity of meaning as possible, so it's a good idea to keep paragraphs and avoid separations within sentences. Short pieces (like dialogue lines) can be combined into larger ones, and larger paragraphs can be split by sentence boundaries to keep the word count in check. This corpus has plenty of dialogue lines, and a few paragraphs longer than 180 words. Both of these transformations are done in our preprocessing scripts, alongside the fixing of page-spanning paragraphs. 

```
(hp-corpus) harry-potter-corpus $ ./process.sh 
Processing Book1.txt... 
Processing Book2.txt... 
Processing Book3.txt... 
Processing Book4.txt... 
Processing Book5.txt... 
Processing Book6.txt... 
Processing Book7.txt... 
corpus.tsv successfully generated. 
(hp-corpus) harry-potter-corpus $ 
```

Let's take a look at the result: 

```
(hp-corpus) harry-potter-corpus $ less -SX corpus.tsv 
id      text    title 
1        / THE BOY WHO LIVED Mr. and Mrs. Dursley, of number four, Privet Dr> 
2       The Dursleys had everything they wanted, but they also had a secret,> 
3       When Mr. and Mrs. Dursley woke up on the dull, gray Tuesday our stor> 
4       It was on the corner of the street that he noticed the first sign of> 
5       But on the edge of town, drills were driven out of his mind by somet> 
6       Mr. Dursley always sat with his back to the window in his office on > 
7       He’d forgotten all about the people in cloaks until he passed a grou> 
8       He dashed back across the road, hurried up to his office, snapped at> 
9       “Sorry,” he grunted, as the tiny old man stumbled and almost fell. I> 
10      As he pulled into the driveway of number four, the first thing he sa> 
11      Mrs. Dursley had had a nice, normal day. She told him over dinner al> 
: 
```

As you can see, we've arranged the corpus in the expected tabular form, listing one "document" per line (in our case, a paragraph), a sequential id before it, and a title with the Book<N> Paragraph <M> pattern at the right end of each line: 

 
```
was no finer boy anywhere.    Book1 Paragraph 1 
dley mixing with a child like that.   Book1 Paragraph 2 
se. He got into his car and backed out of number four’s drive.        Book1 > 
is mind. As he drove toward town he thought of nothing except a large order > 
en it struck Mr. Dursley that this was probably some silly stunt — these peo> 
 
 
 same, those people in cloaks ...  He found it a lot harder to concentrate o> 
atever that was. He was rattled. He hurried to his car and set off for home,> 
 
lowed himself a grin. “Most mysterious. And now, over to Jim McGuffin with t> 
: 
```

The inner workings of the `process.sh` script are described below. 

## Processing steps

`process.sh` is a Bash script that streams the books' contents into a series of pipelined modification steps:

- Using `sed` regular expression replacements, turn page footer occurrences into empty lines (first three steps). 
- With the fourth `sed` command, turn lines containing only spaces into empty lines. 
- `remove_multi_newline.py` collapses three or more contiguous newlines into a single empty line. 
- `remove_single_newline.py` removes single newlines so paragraphs get consolidated into the same line, one per line. 
- `fix_straddling_paragraphs.py` fixes page break-straddling paragraphs checking sentence continuity (one paragraph per line up to this point). 
- `combine_up_to_n_words.py` combines contiguous short paragraphs as long as the result doesn't exceed 180 words. 
- `split_by_sentences_up_to_n_words.py` splits paragraphs longer than 180 words, keeping whole sentences. 
- `to_tsv.py` formats each piece as `tsv` appending `Book<N> Paragraph <M>` as title. 

The first steps are implemented with simple Bash commands, while the later steps, such as the sentence-aware ones, are implemented as Python scripts with spaCy. 

```
readonly WORD_QTY="${1:-180}" 
 
for book in Book*.txt; do 
  >&2 echo "Processing ${book}..." 
  cat "${book}" \ 
    | sed -E 's/^Page \|\s*[0-9]+ .*$//g' \ 
    | sed -E 's/^P a g e.*$//g' \ 
    | sed -E 's/P.*Rowling//g' \ 
    | sed -E 's/^\s+$//g' \ 
    | ./remove_multi_newline.py \ 
    | ./remove_single_newline.py \ 
    | ./fix_straddling_paragraphs.py \ 
    | ./combine_up_to_n_words.py "${WORD_QTY}" \ 
    | ./to_tsv.py "${book%.*}" \ 
    | cat > "${book%.*}.tsv" 
done 
```

Each book gets into an intermediate `tsv` representation of one "document" per line, being each one of these either an original paragraph, whole sentences of a long paragraph or a concatenation of short paragraphs or dialogue lines. 

After processing each book, the seven intermediate representations are concatenated after a `id<TAB>text<TAB>title` header into a single stream, in which each line is preceded by a line number: 

```
cat Book*.tsv \ 
  | nl \ 
  | sed 's/^ *//g' \ 
  | { echo -e 'id\ttext\ttitle'; cat; } \ 
  | cat > corpus.tsv 
```

When the process finishes, the `corpus.tsv` file is ready to be used by PrimeQA's indexing feature. 

