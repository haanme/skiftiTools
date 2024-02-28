.. documentation master file, created by sphinx-quickstart 
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

skiftiTools
================================

.. raw:: html

.. role:: red

.. This main document is in `'reStructuredText' ("rst") format

Analysis of three and four dimensional brain imaging data in various statistical settings there is growing invitation in tools facilitating data analysis in more tool independent manner. In brain image analysis, Tract-Based Spatial Statistics (TBSS) is a conventionally used tool to make statistical calculations in voxel-space for brain imaging data. While they provide support for basic statistical tests needed in neuroscience, with larger datasets and more complex test settings, their use becomes cumbersome. More sophisticated statistical operations are not supported.

skiftiTools provides a versatile package facilitating use of vast amount of statistical operations in R and other tools by writing tab separated values ASCII files which are easily readable by most commonly used statistical tools such as R language (RStudio), SPSS, SAS, GraphPad prism. After statistical processing, the resulting ASCII data can be then again read for visualization. The package supports Nifti image format, tab separated ASCII format, and its own stand-alone format for efficient disk usage. It is open source (https://github.com/haanme/skiftiTools), built on R-language and has easy installation from R’s CRAN package repository. In addition, it has basic functions available in docker containers for further planform independence.

image:: ../images/Figure1.jpg

Examples
--------

All of the following are defined within the ``docs/index.rst`` file. Here is
some :red:`coloured` text which demonstrates how raw HTML commands can be
incorporated. The following are examples of ``rst`` "admonitions":

.. note::

    Here is a note

    .. warning::

        With a warning inside the note

.. seealso::

    The full list of `'restructuredtext' directives <https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html>`_ or a similar list of `admonitions <https://restructuredtext.documatt.com/admonitions.html>`_.

.. centered:: This is a line of :red:`centered text`

.. hlist::
   :columns: 3

   * and here is
   * A list of
   * short items
   * that are
   * displayed
   * in 3 columns

The remainder of this document shows three tables of contents for the main
``README`` (under "Introduction"), and the vignettes and R directories of
a package. These can be restructured any way you like by changing the main
``docs/index.rst`` file. The contents of this file -- and indeed the contents
of any `readthedocs <https://readthedocs.org>`_ file -- can be viewed by
clicking *View page source* at the top left of any page.

.. toctree::
   :maxdepth: 1
   :caption: Introduction:
