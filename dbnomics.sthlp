{smcl}
{* *! version 1.1.2  30oct2018}{...}
{viewerjumpto "Syntax" "dbnomics##syntax"}{...}
{viewerjumpto "Description" "dbnomics##description"}{...}
{viewerjumpto "Options" "dbnomics##options"}{...}
{viewerjumpto "Remarks" "dbnomics##remarks"}{...}
{viewerjumpto "Examples" "dbnomics##examples"}{...}
{viewerjumpto "Stored results" "dbnomics##stored"}{...}
{viewerjumpto "Author" "dbnomics##author"}{...}

{title:Title}

{phang}
{bf:dbnomics} {hline 2} Stata client for DB.nomics, the world's economic database ({browse "https://db.nomics.world":https://db.nomics.world})

{marker description}{...}
{title:Description}

{pstd}
{cmd:dbnomics} provides a suite of tools to search, browse and import time series data from DB.nomics, the world's economic database ({browse "https://db.nomics.world":https://db.nomics.world}).
DB.nomics is a web-based platform that aggregates and maintains time series data from various statistical agencies across the world.
{cmd:dbnomics} only works with Stata 14.0 or higher, since it relies on the secure HTTP protocol ({it:https}).

{pstd}
{cmd:dbnomics} provides an interface to DB.nomics' RESTful API ({browse "https://api.db.nomics.world/apidocs":https://api.db.nomics.world/apidocs}), allowing for the advanced filtering of data using Stata's 
native {help options:options} syntax (see {help dbnomics##examples:Examples}). To achieve this, the command relies on Erik Lindsley's libjson backend ({stata ssc install libjson:ssc install libjson}).

{marker syntax}{...}
{title:Syntax}

{p 8 8 2} {it: Load list of providers} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:provider:s} [{cmd:,} {opt clear}] {p_end}

{p 8 8 2} {it: Load content tree for a given provider} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:tree} {cmd:,} {opt pr:ovider(PRcode)} [{opt clear}] {p_end}

{p 8 8 2} {it: Load dataset structure given a provider and dataset} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:data:structure} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{opt clear} {opt nostat}] {p_end}

{p 8 8 2} {it: Load list of series for a given provider and dataset} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:series} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{opt clear} {opt limit(int)} {it:dimensions_opt}] {p_end}

{p 8 8 2} {it: Import series for a given provider and dataset} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:import} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{opt clear} {opt limit(int)} {opt series:ids(SERIES_list)} {opt sdmx(SDMX_mask)} {it:dimensions_opt}] {p_end}

{p 8 8 2} {it: Search for data across DB.nomics' providers} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:find} {it:search_str} [{cmd:,} {opt clear} {opt limit(int)} {opt all}] {p_end}

{p 8 8 2} {it: Load and display recently updated datasets} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:news} [{cmd:,} {opt clear} {opt limit(int)} {opt all}] {p_end}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{bf:provider(}{it:PRcode}{bf:)}}declare the reference data provider ({it:e.g.} AMECO, IMF, Eurostat) {p_end}
{synopt:{bf:dataset(}{it:DScode}{bf:)}}declare the reference dataset ({it:e.g.} PIGOT, BOP, ei_bsin_m) {p_end}
{synopt:{bf:clear}}replace data in memory {p_end}

{syntab:For {cmd:datastructure} only}
{synopt:{bf:nostat}}disable the parsing of series statistics (may speed up importing){p_end}

{syntab:For {cmd:series} and {cmd:import} only}
{synopt:{bf:limit(}{it:int}{bf:)}}set the limit for the number of series to load{p_end}
{synopt:{it:dimensions_opt}}provider- and dataset-specific options to filter series (see {help dbnomics##examples:Examples}){p_end}

{syntab:For {cmd:import} only}
{synopt:{bf:seriesids(}{it:SERIES_list}{bf:)}}input a comma-separated list to load specific time series{p_end}
{synopt:{bf:sdmx(}{it:SDMX_mask}{bf:)}}input an SDMX mask to select specific series ({bf:Note:} not all providers support this option){p_end}

{syntab:For {cmd:find} and {cmd:news} only}
{synopt:{bf:limit(}{it:int}{bf:)}}maximum number of results to display{p_end}
{synopt:{bf:all}}show all results {p_end}
{synoptline}
{p2colreset}{...}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt provider(PRcode)} sets the source that contains the data of interest. The list of data providers is continuously updated by the DB.nomics team. 
To obtain the most recent list of active data providers, use the command {cmdab:dbnomics} {cmdab:provider:s} [{cmd:,} {opt clear}].{p_end}

{phang}
{opt dataset(DScode)} sets the source dataset for the time series of interest. A category tree containing all datasets associated with each {opt provider(PRcode)}
can be obtained via the command {cmdab:dbnomics} {cmdab:tree}{cmd:,} {cmdab:pr:ovider(}{it:PRcode}{cmd:)} [{opt clear}]. ({bf:Note:} not all datasets available in the category tree may be accessible). {p_end}

{phang}
{opt clear} clears data in memory before importing data from DB.nomics. {p_end}

{bf:{dlgtab:datastructure}}

{phang}
{opt nostat} disables the parsing of series statistics. By default, the command {cmdab:dbnomics} {cmdab:data:structure} {cmd:, {opt (...)}} also collects 
information on the number of time series associated with each dataset dimension value. Using the {cmd:nostat} option disables this additional parsing of data, speeding up the loading process.{p_end}

{bf:{dlgtab:series/import}}

{phang}
{opt limit(int)} sets the maximum number of series to load. It limits the number of series identified by the {cmd:dbnomics series} or {cmd:dbnomics import} commands, resulting in faster download of information. 
A {err:Warning} message is issued if the total number of series identified is larger than the inputted {opt limit(int)}. {p_end}

{phang}
{opt dimensions_opt(dim_values)} are {opt provider(PRcode)}{cmd:-} and {opt dataset(DScode)}{cmd:-}specific options that can be used to identify series. 
A list of dimensions can be obtained using {cmd: dbnomics datastructure,} {opt provider(PRcode)} {opt dataset(DScode)}. 
For instance, assuming the dimensions of {opt dataset(DScode)} to be {cmd:freq.unit.geo}, accepted options for{cmd: dbnomics series,}{opt (...)} and {cmd: dbnomics import,}{opt (...)} 
are {opt freq(codelist)}, {opt unit(codelist)} and {opt geo(codelist)}. 
Each {opt dimension_opt(dim_values)} can contain one or more values in a space or comma-separated list, so as to select multiple dimensions at once ({it:e.g.}, a list of countries). 
{it:Note:} {cmd:dbnomics} does not carry a validation check on user-inputted {opt dimension_opt(dim_values)}; 
if a {opt dimension_opt(dim_values)} is invalid, {cmd:dbnomics} will likely return the message {err:Warning: no series found}. See {help dbnomics##examples:Examples}. {p_end}

{bf:{dlgtab:import}}

{phang}{it:Note}: the options below are mutually exclusive and are alternatives to {opt dimensions_opt(dim_values)}. {p_end}

{phang}
{opt seriesids(SERIES_list)} accepts a comma-separated list of names corresponding to series available in {opt provider(PRcode)} and {opt dataset(DScode)}. Each series is then imported accordingly. {p_end}

{phang}
{opt sdmx(SDMX_mask)} accepts an SDMX REST query ("SDMX mask") containing dimensions to identify series for a {opt provider(PRcode)} and {opt dataset(DScode)} that supports this function. 
A list of dimensions can be obtained using {cmd: dbnomics datastructure,} {opt provider(PRcode)} {opt dataset(DScode)}. {bf:Note:} not all providers will support this feature. 
In such case {cmd: dbnomics import, }{opt (...)} may return a {err:Warning: no series found} error. {p_end}

{bf:{dlgtab:find/news}}

{phang}{opt limit(int)} sets the maximum number of results to load and display. {p_end}
{phang}{opt all} forces the download and display of all matching results. {bf:Note:} this option may cause a server failure for queries with a large number of results.{p_end}

{phang}


{marker remarks}{...}
{title:Remarks}

{pstd} This program has two main dependencies: {p_end}

{pstd} 1) The Mata json library {cmd:libjson} by Erik Lindsley is needed to parse JSON strings. It can be found on SSC: {stata ssc install libjson}. {p_end}
{pstd} 2) The routine {cmd:moss} by Robert Picard & Nicholas J. Cox is needed to clean unicode sequences. It can be found on SSC: {stata ssc install moss}. {p_end}

{pstd} After each API call, {cmd:dbnomics} stores significant metadata in the form of {help char:dataset characteristics}. 
Type {cmd:{stata "char li _dta[]":char li _dta[]}} after {cmd:dbnomics} to obtain important info about the data, {it:e.g.}, the API endpoint. {p_end}

{marker examples}{...}
{title:Examples}

{pstd}{it:Load the list of available providers with additional metadata:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:provider:s}{cmd:, clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics providers, clear":click to run})}

{pstd}{it:Load the dataset tree of of the {bf:AMECO} provider:}{p_end}
{space 8}{cmd:. dbnomics tree, }{cmdab:pr:ovider}{cmd:(AMECO) clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics tree, provider(AMECO) clear":click to run})}

{pstd}{it:Analyse the structure of dataset {bf:PIGOT} for provider {bf:AMECO}:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:data:structure}{cmd:, }{cmdab:pr:ovider}{cmd:(AMECO) {cmdab:d:ataset}{cmd:(PIGOT)} clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics datastructure, provider(AMECO) dataset(PIGOT) clear":click to run})}
{space 8}{cmd:Price deflator gross fixed capital formation: other investment}
{space 8}86 series found. Order of dimensions: (freq.unit.geo)

{pstd}{it:List all series in {bf:AMECO/}{bf:PIGOT} containing deflators in national currency:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:series}{cmd:, }{cmdab:pr:ovider}{cmd:(AMECO) {cmdab:d:ataset}{cmd:(PIGOT)} {cmd:unit(national-currency-2010-100)} clear}
{space 8}{txt:({stata "dbnomics series, provider(AMECO) dataset(PIGOT) unit(national-currency-2010-100) clear":click to run})}
{space 8}40 of 86 series selected. Order of dimensions: (freq.unit.geo)

{pstd}{it:Import all series in {bf:AMECO/}{bf:PIGOT} containing deflators in national currency:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(AMECO) {cmdab:d:ataset}{cmd:(PIGOT)} {cmd:unit(national-currency-2010-100)} clear}
{space 8}{txt:({stata "dbnomics import, provider(AMECO) dataset(PIGOT) unit(national-currency-2010-100) clear":click to run})}
{space 8}........................................
{space 8}40 series found and imported

{pstd}{it:Import single {bf:AMECO/}{bf:PIGOT} series:}{p_end}
{space 8}{cmd:. dbnomics import, pr(AMECO) d(PIGOT) }{cmdab:series:ids}{cmd:(ESP.3.1.0.0.PIGOT,SVN.3.1.0.0.PIGOT,LVA.3.1.99.0.PIGOT) clear}
{space 8}{txt:({stata "dbnomics import, pr(AMECO) d(PIGOT) seriesids(ESP.3.1.0.0.PIGOT,SVN.3.1.0.0.PIGOT,LVA.3.1.99.0.PIGOT) clear":click to run})}
{space 8}...
{space 8}3 series found and imported

{pstd}{it:{bf:Eurostat} typically supports SMDX queries}{p_end}
{pstd}{it:Import all series in {bf:Eurostat/}{bf:ei_bsin_q_r2} related to Belgium:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(Eurostat) {cmdab:d:ataset}{cmd:(ei_bsin_q_r2)} {cmd:geo(BE) s_adj(NSA)} clear}
{space 8}{txt:({stata "dbnomics import, provider(Eurostat) dataset(ei_bsin_q_r2) geo(BE) s_adj(NSA) clear":click to run})}
{space 8}..............
{space 8}14 series found and imported

{pstd}{it:Do the same using {cmd:sdmx}:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(Eurostat) {cmdab:d:ataset}{cmd:(ei_bsin_q_r2)} {cmd:sdmx(Q..NSA.BE)} clear}
{space 8}{txt:({stata "dbnomics import, provider(Eurostat) dataset(ei_bsin_q_r2) sdmx(Q..NSA.BE) clear":click to run})}
{space 8}..............
{space 8}14 series found and imported

{pstd}{it:Show recently updated datasets:}{p_end}
{space 8}{cmd:. dbnomics news, clear}
{space 8}{txt:({stata "dbnomics news, clear ":click to run})}
{space 8}{it:(output omitted)}

{pstd}{it:Find topic of interest in DB.nomics' data:}{p_end}
{space 8}{cmd:. dbnomics find "producer price", clear}
{space 8}{txt:({stata `"dbnomics find "producer price", clear "':click to run})}
{space 8}{it:(output omitted)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:dbnomics} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Local}{p_end}
{synopt:{cmd:endpoint}}name of {cmd:dbnomics} subcommand{p_end}
{synopt:{cmd:cmd#}}command to load # result shown (For {cmd:find} and {cmd:news} only){p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}
	Simone Signore{break}
	signoresimone at yahoo [dot] it {p_end}
	https://dreameater89.github.io/dbnomics/

