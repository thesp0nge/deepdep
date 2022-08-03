# deepdep

Find deprecated API calls in your Java code

## The goal

I wrote this script during a whitebox audit on an big J2EE codebase. Analyzing
a file, I googled of xml related vulnerabilities, when I read this line of
code:

```
parser = XMLReaderFactory.createXMLReader(DEFAULT_PARSER_NAME);
```

What I found is that this API is marked as deprecated and the following one is
suggested to be used instead:

```
SAXParserFactory parserFactory = SAXParserFactory.newInstance();
SAXParser parser = parserFactory.newSAXParser();
XMLReader reader = parser.getXMLReader();
```

So, since in my worflow I don't use a SAST tool (tl;dr too much noise for my
taste), I wrote a simple script to help me grepping for deprecated APIs.

## Some Q&A

Q:  Why don't you use a SAST tool to spot this?
A:  This script is intended as a small and quick companion to the whitebox
    source code auditing. Different people means different setups and different
    tools and different way of do audits. Maybe there is someone doesn't like SAST.
Q:  Do you now that javac spots deprecated API?
A:  Yes but sometimes there is no easy way to compile the source code you want
    to audit (e.g. missing third party libraries, errors in the code, missing
    required binaries, ...)
Q:  Do you know it is prone to false positives?
A:  Sure. This script won't me grant a Turing Award, it's just a bunch of grep
    touches to spot deprecated APIs without going deeper into the source code
    context. It is possible that Oracle deprecates only a constructor or only a
    particular method prototype and so deepdep will raise a false positive. I'm
    sorry about it, but this code goal is to help me in reviewing the code, it's
    not supposed to go in a CI/CL pipe without manual review.
Q:  How api.txt is built?
A:  api.txt file is built scraping Oracle deprecated API page using the dep.py
    script you can find in aux/ folder in this repository.
