
This MATLAB source code provides an implementation along with examples
of a the diferent modulations candidate to substitute OFDM in the next 
generation of cellular systems 5G. I am sharing them with the idea of 
letting other members in the research community, who are working on the 
same or similar fields, to take advantage of our efforts and be able to 
repeat and improve our same experiments in their respective labs. 

It contains both transmitter and receiver ends for OOK, OFDM, FBMC, GFDM,
and UFMC multicarrier modulations. They are standalone and can be adapted 
for all types of simulation.

These codes have been built by Albert Gran Alcoz from Universitat Politècnica
de Catalunya, while working under the Optical Communications Lab. Albert, however,
is only responsible for the adaptations performed. Licenses from the original 
sources cited below should be taken into consideration. 

OFDM, FBMC and UFMC codes have been created departing from the examples provided by 
Mathworks, available to the public in the following links: 

https://es.mathworks.com/help/comm/examples/fbmc-vs-ofdm-modulation.html
https://es.mathworks.com/help/comm/examples/ufmc-vs-ofdm-modulation.html

GFDM codes are just an adaptation of the 5GNOW test vector provided by
Vodafone chair/TU Dresden in: http://5gnow.eu/?page_id=427
They are not standalone. Notice that for them to work properly, the GFDM library 
available on the link above should be included in the project before execution.
 
Copyright (c) 2014 Technical University Dresden, Vodafone Chair Mobile Communication Systems
All rights reserved.

In case you have any doubt of implementation, please do not heasitate to contact:
albert.gran@alu-etsetb.upc.edu