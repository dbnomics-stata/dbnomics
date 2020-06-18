# dbnomics
Stata client for DB.nomics, the world's economic database (https://db.nomics.world)

## Description

dbnomics provides a suite of tools to search, browse and import time series data from DB.nomics, the world's economic database (https://db.nomics.world).  DB.nomics is a web-based platform that aggregates and maintains time series data from various statistical agencies across the world.  dbnomics only works with Stata 14.0 or higher.
 
dbnomics provides an interface between Stata and DB.nomics' API (https://api.db.nomics.world/apidocs). It enables creating custom queries through Stata's options syntax (see Examples). To achieve this, the command relies on Erik Lindsley's libjson Mata library (ssc install libjson).

## Installation

`net install dbnomics, from("https://dbnomics-stata.github.io/dbnomics")`

## Syntax

```Stata
. //Load list of providers
. dbnomics providers [, clear insecure]

. //Load content tree for a given provider
. dbnomics tree , provider(PRcode) [clear insecure]

. //Load dataset structure given a provider and dataset
. dbnomics datastructure , provider(PRcode) dataset(DScode) [clear insecure]

. // Load list of series for a given provider and dataset
. dbnomics series , provider(PRcode) dataset(DScode) [dimensions_opt|sdmx(SDMX_mask)] [clear insecure limit(int) offset(int)]

. // Import series for a given provider and dataset
. dbnomics import , provider(PRcode) dataset(DScode) [dimensions_opt|sdmx(SDMX_mask)|seriesids(SERIES_list)] [clear insecure limit(int) offset(int)]

. // Load a single series
. dbnomics use series_id , provider(PRcode) dataset(DScode) [clear insecure]

. // Search for data across DB.nomics' providers
. dbnomics find search_str [, clear insecure limit(int) offset(int)]

. // Load and display recently updated datasets
. dbnomics news [, clear insecure limit(int) offset(int)]
```

## Options
### Main

- **provider(**PRcode**)** sets the source with the data of interest. The list of data providers is regularly updated by the DB.nomics team.  To get the list of available data providers, type **dbnomics providers [, clear]**.

- **dataset(**DScode**)** sets the dataset with the time series of interest.  To get a hierarchy of all datasets linked to a particular provider(*PRcode*), type **dbnomics tree, provider(PRcode) [clear]**. (**Note**: some datasets in the category tree may not be accessible).

- **clear** clears data in memory before loading data from DB.nomics.

- **insecure** instructs dbnomics to access the DB.nomics platform via the http protocol, instead of the more secure https.

### series

- **dimensions_opt(**dim_values**)** are options that depend on the specific provider(*PRcode*) and dataset(*DScode*) and are used to identify a subset of series.  A list of dimensions can be obtained using **dbnomics datastructure, provider(PRcode) dataset(DScode)**.  For example, if the dimensions of dataset(*DScode*) are *freq.unit.geo*, accepted options for **dbnomics series,(...)** and **dbnomics import,(...)** are **freq(**codelist**)**, **unit(**codelist**)** and **geo(**codelist**)**.  Each **dimension_opt(**dim_values**)** can contain one or more values in a space or comma-separated list, so as to select multiple dimensions at once (*e.g.*, a list of countries).  **Note:** dbnomics is not able to validate user-inputted **dimension_opt(**dim_values**)**; if **dimension_opt(**dim_values**)** is incorrectly specified, dbnomics may throw an error or return the message no series found. See the Examples section.

- **sdmx(**SDMX_mask**)** accepts an "SDMX mask" containing a list of dimensions separated with a dot "." character.  The dimensions are specific to each provider(*PRcode*) and dataset(*DScode*) and must be provided in the order specified by the dataset(*DScode*) data structure.  The data structure can be obtained using **dbnomics datastructure, provider(PRcode) dataset(DScode)**. **Note:** some providers do not support this feature.  In such case dbnomics may throw an error or return the message "no series found". See the Examples section.

**Note:** **dimensions_opt(**dim_values**)** and **sdmx(**SDMX_mask**)** are mutually exclusive.

- **limit(**int**)** sets the maximum number of series to load. It limits the number of series identified by the **dbnomics series** or **dbnomics import** commands, resulting in faster download of information.  A Warning message is issued if the total number of series identified is larger than the inputted limit(int).

- **offset(**int**)** skips the first int series when loading data from dbnomics. This option can be combined with **limit(**int**)** to get a specific subset of series.

### import

- **dimensions_opt(**dim_values**)** see above.

- **sdmx(**SDMX_mask**)** see above.

- **seriesids(**SERIES_list**)** accepts a comma-separated list of series
identifiers that belong to a provider(*PRcode*) and dataset(*DScode*).

**Note:** **dimensions_opt(**dim_values**)**, **sdmx(**SDMX_mask**)** and **seriesids(**SERIES_list**)** are mutually exclusive.

- **limit(**int**)** sets the maximum number of series to load. It limits the number of series identified by the **dbnomics series** or **dbnomics import** commands, resulting in faster download of information.  A Warning message is issued if the total number of series identified is larger than the inputted limit(int).

- **offset(**int**)** skips the first int series when loading data from dbnomics. This option can be combined with **limit(**int**)** to get a specific subset of series. See the Examples section.

### use

- series_id is the unique identifier of a time series belonging to provider(*PRcode*) and dataset(*DScode*).

### find/news

- **limit(**int**)** sets the maximum number of results to load and display.

- **offset(**int**)** skips the first int results. May be combined with **limit(**int**)** to get a specific subset of results.

## Remarks

**dbnomics** has two main dependencies:

1. The Mata json library **libjson** by Erik Lindsley, needed to parse JSON strings. It can be found on SSC: `ssc install libjson`.
2. The routine **moss** by Robert Picard & Nicholas J. Cox, needed to clean unicode sequences. It can be found on SSC: `ssc install moss`.

After each API call, dbnomics stores significant metadata in the form of dataset characteristics.  Type *char li _dta[]* after dbnomics to obtain important info about the data, e.g., the API endpoint.

## Examples

```Stata
. // Search for producer price data on DB.nomics' platform:
. dbnomics find "producer price", clear
(output omitted)

. // Load the list of available providers with additional metadata:
. dbnomics providers, clear
Fetching providers list
(63 providers read)

. // Show recently updated datasets:
. dbnomics news, clear
(output omitted)

. // Load the dataset tree of of the AMECO provider:
. dbnomics tree, provider(AMECO) clear

. // Analyse the structure of dataset PIGOT for provider AMECO:
. dbnomics datastructure, provider(AMECO) dataset(PIGOT) clear
Price deflator gross fixed capital formation: other investment
82 series found. Order of dimensions: (freq.unit.geo)

. // List all series in AMECO/PIGOT containing deflators in national currency:
. dbnomics series, provider(AMECO) dataset(PIGOT) unit(national-currency-2015-100) clear
39 of 82 series selected. Order of dimensions: (freq.unit.geo)

. // Import all series in AMECO/PIGOT containing deflators in national currency:
. dbnomics import, provider(AMECO) dataset(PIGOT) unit(national-currency-2015-100) clear
Processing 39 series
........................................
39 series found and imported

. // Import a few AMECO/PIGOT series:
. dbnomics import, pr(AMECO) d(PIGOT) seriesids(ESP.3.1.0.0.PIGOT,SVN.3.1.0.0.PIGOT,LVA.3.1.99.0.PIGOT) clear
Processing 3 series
...
3 series found and imported

. // Import one specific series from AMECO/PIGOT:
. dbnomics use ESP.3.1.0.0.PIGOT, pr(AMECO) d(PIGOT) clear
Annually – (National currency: 2015 = 100) – Spain (AMECO/PIGOT/ESP.3.1.0.0.PIGOT)
(62 observations read)

. // Eurostat supports SMDX queries. Import all series in Eurostat/ei_bsin_q_r2 related to Belgium:
. dbnomics import, provider(Eurostat) dataset(ei_bsin_q_r2) geo(BE) s_adj(NSA) clear
Processing 14 series
..............
14 series found and imported

. // Do the same using sdmx:
. dbnomics import, provider(Eurostat) dataset(ei_bsin_q_r2) sdmx(Q..NSA.BE) clear
Processing 14 series
..............
14 series found and imported

. // The Eurostat/urb_ctran dataset offers 12280 series, more than permitted at once by DB.nomics:
. dbnomics series, provider(Eurostat) dataset(urb_ctran) clear
Warning: series set larger than dbnomics maximum provided items.
Use the offset option to load series beyond the 1000th one.
12280 series selected. Order of dimensions: (FREQ.indic_ur.cities). Only #1 to #1000 retrieved

. // Using limit and offset, we can instruct dbnomics to only get series #1001 to #1100:
. dbnomics import, provider(Eurostat) dataset(urb_ctran) limit(100) offset(1000) clear
Processing 100 series
..................................................    50
..................................................   100
12280 series found and #1001 to #1100 loaded
```

## Bugs?

Write at: signoresimone at yahoo [dot] it
