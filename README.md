[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/TheTS/actigraph.sleepr?branch=master&svg=true)](https://ci.appveyor.com/project/TheTS/actigraph-sleepr) [![Travis-CI Build Status](https://travis-ci.org/TheTS/actigraph.sleepr.svg?branch=master)](https://travis-ci.org/TheTS/actigraph.sleepr) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/actigraph.sleepr)](https://cran.r-project.org/package=actigraph.sleepr) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.2.4-6666ff.svg)](https://cran.r-project.org/) [![packageversion](https://img.shields.io/badge/Package%20version-0.1.0-orange.svg?style=flat-square)](commits/master) [![Last-changedate](https://img.shields.io/badge/last%20change-2018--04--22-yellowgreen.svg)](/commits/master) [![codecov](https://codecov.io/gh/TheTS/actigraph.sleepr/branch/master/graph/badge.svg)](https://codecov.io/gh/TheTS/actigraph.sleepr)

<!-- README.md is generated from README.Rmd. Please edit that file -->
### actigraphr: Non-wear, sleep, and physical activity analysis from ActiGraph data

The `actigraphr` package is used to analyse accelerometer data obtaiend from ActiGraph devices. It includes several non-wear, sleep, and physical activity detection algorithms.

This package is an extension of the [`actigraph.sleepr`](https://github.com/dipetkov/actigraph.sleepr) package, written by Desislava Petkova.

Non-wear detection algorithms \* Troiano (Troiano et al. 2008) \* Choi (Choi et al. 2011)

Sleep scoring algorithms \* Sadeh (Sadeh, Sharkey, and Carskadon 1994) \* Cole-Kripke (Cole et al. 1992) \* Tudor-Locke (Tudor-Locke et al. 2014)

Physical activity thresholds \* Freedson adult (Freedson, Melanson, and Sirard 1998) \* Freedson adult VM (Sasaki, John, and Freedson 2011) \* Freedson children (Freedson, David, and Janz 2005) \* Evenson children (Evenson et al. 2008) \* Mattocks children (Mattocks et al. 2007) \* Puyau children (Puyau et al. 2007)

### Installation

``` r
library("devtools")
install_github("TheTS/actigraphr")
```

### Examples

Documentation is on its way!

### References

Choi, Leena, Zhouwen Liu, Charles E. Matthews, and Maciej S. Buchowski. 2011. “Validation of Accelerometer Wear and Nonwear Time Classification Algorithm.” *Medicine & Science in Sports & Exercise* 43 (2): 357–64.

Cole, Roger J, Daniel F Kripke, William Gruen, Daniel J Mullaney, and J Christian Gillin. 1992. “Automatic Sleep/Wake Identification from Wrist Activity.” *Sleep* 15 (5): 461–69.

Evenson, Kelly R, Diane J Catellier, Karminder Gill, Kristin S Ondrak, and Robert G McMurray. 2008. “Calibration of Two Objective Measures of Physical Activity for Children.” *Journal of Sports Sciences* 26 (14): 1557–65.

Freedson, Patty S, Pober David, and Kathleen F Janz. 2005. “Calibration of Accelerometer Output for Children.” *Medicine & Science in Sports & Exercise* 37 (11): S523–S530.

Freedson, Patty S, Edward Melanson, and John Sirard. 1998. “Calibration of the Computer Science and Applications, Inc. Accelerometer.” *Medicine & Science in Sports & Exercise* 30 (5): 777–81.

Mattocks, Calum, Sam Leary, Andy Ness, Kevin Deere, Joanne Saunders, Kate Tilling, Joanne Kirkby, Steven N Blair, and Chris Riddoch. 2007. “Calibration of an Accelerometer During Free‐living Activities in Children.” *Pediatric Obesity* 2 (4): 218–26.

Puyau, Maurice R, Anne L Adolph, Firoz A Vohra, and Nancy F Butte. 2007. “Validation and Calibration of Physical Activity Monitors in Children.” *Obesity* 10 (3): 150–57.

Sadeh, Avi, Katherine M Sharkey, and Mary A Carskadon. 1994. “Activity Based Sleep-Wake Identification: An Empirical Test of Methodological Issues.” *Sleep* 17 (3): 201–7.

Sasaki, Jeffer E, Dinesh John, and Patty S Freedson. 2011. “Validation and Comparison of Actigraph Activity Monitors.” *Journal of Science and Medicine in Sport* 14 (5): 411–16.

Troiano, Richard P, David Berrigan, Kevin W Dodd, Louise C Mâsse, Timothy Tilert, and Margaret McDowell. 2008. “Physical Activity in the United States Measured by Accelerometer.” *Medicine & Science in Sports & Exercise* 40 (1): 181–88.

Tudor-Locke, Catrine, Tiago V. Barreira, John M. Schuna, Emily F. Mire, and Peter T. Katzmarzyk. 2014. “Fully Automated Waist-Worn Accelerometer Algorithm for Detecting Children’s Sleep-Period Time Separate from 24-H Physical Activity or Sedentary Behaviors.” *Applied Physiology, Nutrition, and Metabolism* 39 (1): 53–57.
