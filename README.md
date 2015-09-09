# STAT215A-Lab1
Lab1- Redwood dataset
#Introduction
The redwood dataset was collected by 4 different sensors which are installed in a mote. They deployed those motes around the tree and try to capture the microclimate surrounding the tree over time. Even though the data they collected have a bunch of miss values and unreasonable data, this dataset still contain a lot of informative data point to explore.

#The Data
The data was collected by a set of nodes installed around the 70-meter tall red- wood. Each node has 4 sensors which are for temperature, humidity, incident and reflected photosynthetically active solar radiation. They collected data for every 5 minutes for 44 days.
Those nodes are actually deployed under certain strategy. They started the deployment 15m from the group with roughly a 2-meter spacing between each node. They also put most of the nodes on the west side of the tree to provide buffer against the environmental effects. Lastly, those nodes are placed 0.1-1.0m from the truch in order to clearly get the microclimate trend that affects the tree.
The data was returned by two ways. One way is that the network of sensors tracked each sensor’s reading and returned it, while the other is that the data was returned by a local logger which stored the data in a 512KB disk installed on the mote. By doing so, we can make sure one way can compensate for the other way if having some data transmission issues.

