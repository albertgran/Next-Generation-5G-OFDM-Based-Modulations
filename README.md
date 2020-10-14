
# Next Generation 5G OFDM-Based Modulations (OFDM, FBMC, GFDM, and UFMC):

 ## Introduction
 This MATLAB source code provides an implementation along with examples
 of a the diferent modulations candidate to substitute OFDM in the next 
 generation of cellular systems 5G. I am sharing them with the idea of 
 letting other members in the research community, who are working on the 
 same or similar fields, to take advantage of our efforts and be able to 
 repeat and improve our same experiments in their respective labs. 

 ## What is in this repo?
 It contains both transmitter and receiver ends for OOK, OFDM, FBMC, GFDM,
 and UFMC multicarrier modulations. They are standalone and can be adapted 
 for all types of simulation.

 ## Citing this code
Just cite our paper (https://ieeexplore.ieee.org/abstract/document/8751376), and let us know so that we can update the list below :) 
`@INPROCEEDINGS{8751376,
  author={S. {Sarmiento} and A. {Gran} and J. A. {Altabas} and M. {Scalabroni} and S. {Spadaro} and I. {Garces} and J. A. {Lazaro}},
  booktitle={2018 Photonics in Switching and Computing (PSC)}, 
  title={Experimental Assessment of 5-10Gbps 5G Multicarrier Waveforms with Intensity-Modulation Direct-Detection for PONs}, 
  year={2018},
  volume={},
  number={},
  pages={1-3},}
`

 ## Published works using this code
 - Next Generation 5G OFDM-Based Modulations for Intensity Modulation-Direct Detection (IM-DD)Optical Fronthauling (in this repo)
 - Experimental Assessment of 5-10Gbps 5G Multicarrier Waveforms with Intensity-Modulation Direct-Detection for PONs
 - Experimental Assessment of 10Gbps 5G Multicarrier Waveforms for High-layer Split u-DWDM-PON-based Fronthaul 

 ## Note on licenses
 These codes have been built during the Introduction to Research Program from Universitat Politècnica
 de Catalunya, while working under the Optical Communications Lab. 

 I am only responsible for the adaptations performed. Licenses from the original 
 sources cited below should be taken into consideration. 

	OFDM, FBMC and UFMC codes have been created departing from the examples provided by 
	Mathworks, available to the public in the following links: 

	https://es.mathworks.com/help/comm/examples/fbmc-vs-ofdm-modulation.html
	https://es.mathworks.com/help/comm/examples/ufmc-vs-ofdm-modulation.html

	GFDM codes are just an adaptation of the 5GNOW test vector provided by
	Vodafone chair/TU Dresden in: http://5gnow.eu/?page_id=427
	They are not standalone. Notice that for them to work properly, the GFDM library 
	available on the link above should be included in the project before execution.
	
	Note: I have received messages saying that the 5gnow link seems to be down. 
	Here is an alternative: https://github.com/vodafone-chair/gfdm-lib-matlab
 
	Copyright (c) 2014 Technical University Dresden, Vodafone Chair Mobile Communication Systems
	All rights reserved.

 ## Contact
 Let me know if the code was useful to you :)

 In case you have any doubt of implementation, please do not heasitate to contact:
 `albert.gran@alu-etsetb.upc.edu`
