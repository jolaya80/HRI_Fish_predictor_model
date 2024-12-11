# HRI_Fish_predictor_model
Workflow to obtain the data from the HRI (AGRRA methodology) to use as input in the coral reef abundance prediction model.

Process data from HRI - Belize
Summarize by year (2023, 2021, 2018)

Workflow to extract and summarize coral cover, fleshy algal cover, Commercial Fish Biomass, and Herbivorous Fish Biomass from from HRI data.
Summarize by year (2023, 2021, 2018) and at the site level

For detailed methods see: https://oref.maps.arcgis.com/apps/dashboards/bdb35a48e40b49a6b12267e38633fd67

The code for each benthic group that is directly below 100 points marked at 10-cm intervals along the nominally 10-m benthic transects is recorded. Each benthic group is calculated as a proportion by summing the number of points for all its codes and dividing by the total number of available points in the transect length. The percentage cover for each group equals its proportion multiplied by 100. All transects for a given survey are averaged to give a final survey value. 

Coral Cover: The percentage of the reef surface covered by live hard corals, indicating the reef's structural complexity and habitat availability. Values are summirized by Survey. A survey represent a site where several transects are deployed.

Fleshy Macro algae Cover: The proportion of the reef covered by fleshy macro algae, which can out compete corals and signify ecological imbalance when present in high amounts.

FISH ABUNDANCE

For the purposes of this work, only grouper, jacks, barracuda and snapper fish families were included in the commercial fish biomass calculation, and only fish species within the Parrotfish and Surgeon fish families were included in the herbivorous fish biomass calculation.

Fish biomass estimates from size class and length-weight formulas for each surveyed species are calculated by family. Biomass for each individual fish is calculated as a * (S * TL2FL)b, where a and b are the species biomass curve coefficients, S is the size (usually the size class midpoint for the AGRRA fishes), and TL2FL is a species total length to fork length conversion factor, if necessary, depending on the species coefficients provided in FishBase. The current data uses coefficient values collected for each species from FishBase in 2013 (values available upon request).

Summations are then used to calculate the total biomass of a species, group, or family. These summations are then normalized by dividing by the transect area and multiplying by 100 to produce biomass in grams per 100m2. All transect level values are averaged to give a final biomass value per survey. 

COMMERICAL FISH BIOMASS

tLUTJ	Snappers: Lutjanidae
  LANA	Mutton Snapper: Lutjanus analis
	LAPO	Schoolmaster: Lutjanus apodus
	LBUC	Blackfin Snapper: Lutjanus buccanella
	LCYA	Cubera Snapper: Lutjanus cyanopterus
	LGRI	Gray Snapper: Lutjanus griseus
	LJOC	Dog Snapper: Lutjanus jocu
	LMAH	Mahogany Snapper: Lutjanus mahogoni
	LSYN	Lane Snapper: Lutjanus synagris
	OCHR	Yellowtail Snapper: Ocyurus chrysurus

tSERR	Groupers: Epinephelidae
  CCRU	Graysby: Cephalopholis cruentata
	CFUL	Coney: Cephalopholis fulva
	EADS	Rock Hind: Epinephelus adscensionis
	EGUT	Red Hind: Epinephelus guttatus 
	EITA	Jewfish/Goliath Grouper: Epinephelus itajara
	EMOR	Red Grouper: Epinephelus morio
	ESTR	Nassau Grouper: Epinephelus striatus
	MACU	Comb Grouper: Mycteroperca acutirostris
	MBON	Black Grouper: Mycteroperca bonaci
	MINT	Yellowmouth Grouper: Mycteroperca interstitialis
	MMIC	Gag: Mycteroperca microlepis
	MPHE	Scamp: Mycteroperca phenax
	MTIG	Tiger Grouper: Mycteroperca tigris
	MVEN	Yellowfin Grouper: Mycteroperca venenosa

tCARA Jacks: Carangidae
  CRUB	Bar Jack: Caranx ruber
	TFAL	Permit: Trachinotus falcatus

tSPHY Barracuda: Sphyraenidae
  SBAR	Great Barracuda: Sphyraena barracuda
  
HERBIVOROUS FISH BIOMASS
Parrotfish and Surgeon fish families were included in the herbivorous fish biomass calculation.

Surgeonfish: (tACAN)
  ACHI	Doctorfish: Acanthurus chirurgus
  ACOE	Blue Tang: Acanthurus coeruleus
  ATRA	Ocean Surgeonfish: Acanthurus tractus

Parrotfish (tSCAR)
  CROS	Bluelip Parrotfish: Cryptotomus roseus
	SATO	Greenblotch Parrotfish: Sparisoma atomarium
	SAUR	Redband Parrotfish: Sparisoma aurofrenatum
	SCEL	Midnight Parrotfish: Scarus coelestinus
	SCER	Blue Parrotfish: Scarus coeruleus
	SCHR	Redtail Parrotfish: Sparisoma chrysopterum
	SGUA	Rainbow Parrotfish: Scarus guacamaia
	SISE	Striped Parrotfish: Scarus iseri
	SRAD	Bucktooth Parrotfish: Sparisoma radians
	SRUB	Yellowtail Parrotfish: Sparisoma rubripinne
	STAE	Princess Parrotfish: Scarus taeniopterus
	SVET	Queen Parrotfish: Scarus vetula
	SVIR	Stoplight Parrotfish: Sparisoma viride
