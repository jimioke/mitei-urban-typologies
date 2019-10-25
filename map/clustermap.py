import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from matplotlib.colors import Normalize
from matplotlib.collections import PatchCollection
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import Polygon  # for drawing countries in world map
import brewer2mpl as b2m # Brewer colors; view here: http://bl.ocks.org/mbostock/5577023
import itertools
from operator import itemgetter, attrgetter


from matplotlib import rc
rc('font',**{'family':'sans-serif','sans-serif':['computer modern sans-serif']})
## for Palatino and other serif fonts use:
#rc('font',**{'family':'serif','serif':['Palatino']})
rc('text', usetex=True)

#dir = '../output/'
clusfile = '12-clusters-9-factors-ward-scaled-sorted-cityID-lat-lon'

clusDict = {
			1:"Congested Emerging",
			2:"BusTransit Sprawl",
			3:"Congested Boomer",
			4:"BusTransit Dense",
			5:"Hybrid Moderate",
			6:"Hybrid Giant",
			7:"Auto Sprawl",
			8:"Auto Innovative",
			9:"MassTransit Heavyweight",
			10:"MassTransit Moderate",
			11:"MetroBike Giant",
			12:"MetroBike Emerging"						
}


set1H = [
  	'#fb9a99', #lightred
	'#fdbf6f', #lightorange			
	'#e31a1c', #darkred
	'#ff7f00', #darkorange
	'#ffff99', #yellow '#d2b48c', #lightbrown
	'#b15928', #darkbrown
	'#a6cee3', #lightblue
	'#1f78b4', #darkblue
	'#33a02c',  #darkgreen 
	'#b2df8a', #lightgreen
	'#6a3d9a', #darkpurple
	'#cab2d6', #lightpurple
  ]



def plotMap(file,xx=1,yy=12,ss=55):
	filepath = file+'.csv'
	df = pd.read_csv(filepath)
	try:
		df = df.set_index("clusterID")
	except:
		df = df.set_index("cluster")
	plt.figure(figsize=(20,12))
	#m = Basemap(projection='cyl',resolution='c', llcrnrlat=-63,urcrnrlat=90,llcrnrlon=-170,urcrnrlon=180)
	m = Basemap(projection='cyl', llcrnrlat=-63,urcrnrlat=90,llcrnrlon=-170,urcrnrlon=180,resolution='c',fix_aspect=False)
	m.drawmapboundary(color='w',linewidth=0,fill_color='none') #remove boundingbox
	m.drawcountries(linewidth = .5,color='gray')
	m.fillcontinents(color='black',lake_color='white',zorder=0,alpha=0.95) #'gainsboro'
	ax = plt.gca()
	for i in np.arange(xx,yy+1):
		ypt, xpt = m(df['lat'].ix[i].tolist(), df['lon'].ix[i].tolist())
		#pop = df['pop_2016_dem'].ix[i]
		m.scatter(xpt, ypt, alpha=1.0,color=set1H[i-1],edgecolor='black',label=clusDict[i],s = ss) #, s=.000002*pop)
		#plt.text(xpt, ypt, df['city'].ix[i], ha='right')
		#font.set_weight('bold')
		# Label cities
		# for ii, j in df.ix[i].iterrows():
		# 	plt.text(j['lon'] + .1, j['lat'], j['city'],ha='left',color = set1H[i-1], fontweight = 'bold') 
	plt.xlim([-170,165])
	plt.ylim([-60,70])
	#legend = plt.legend(fontsize=16, frameon = 1, markerscale=2,ncol = 4,bbox_to_anchor=(0.5, -.2),loc=8)
	handles, labels = ax.get_legend_handles_labels()
	# sort both labels and handles by labels
	labels, handles = zip(*sorted(zip(labels, handles), key=lambda t: t[0]))
	legend = ax.legend(handles, labels,fontsize=22, frameon = 1,markerscale=2) #, markerscale=2,ncol = 4,bbox_to_anchor=(0.5, -.2),loc=8)
	frame = legend.get_frame()
	frame.set_color('none')
	#frame.set_opacity('0.5')
	plt.tight_layout()
	plt.savefig('worldmap-{}-{}.jpg'.format(xx,yy), bbox='tight', dpi=360,pad_inches=0)
	plt.show()

plotMap(clusfile)
# plotMap('clusterID-13-clusters',1,2)
# plotMap('clusterID-13-clusters',3,4)
# plotMap('clusterID-13-clusters',5,6)
# plotMap('clusterID-13-clusters',7,8)
# plotMap('clusterID-13-clusters',9,10)
# plotMap('clusterID-13-clusters',11,12)


def plotFactorProfile(file):
	df = pd.read_csv(file+'.csv')
	df['cluster'] = clusDict.values()
	df = df.set_index('cluster')
	df = df/df.max()
	#fig,ax = plt.figure(figsize=(18,8))
	df.plot(kind='bar',width=.8,figsize=(20,4.25))
	plt.legend(fontsize=13, loc='lower center', ncol = 5,bbox_to_anchor=[0.5, -.75])
	plt.xticks(rotation=45,fontsize=12,ha='right')
	plt.xlabel('')
	plt.tight_layout()
	#plt.xticks(clusDict.values())

	plt.savefig('factor-profile.jpg', bbox='tight', dpi=360,pad_inches=0)
	plt.show()

#plotFactorProfile('cluster_profiles')
# handles,labels = ax.get_legend_handles_labels()

# lis = []
# seen =set()
# for i in np.arange(len(handles)):
# 	value = (handles[i],labels[i])
# 	lis.append(value)


# lis1 = [item for item in lis if item[1] not in seen and not seen.add(item[1])]
# lis1 = sorted(lis1,key=itemgetter(1))
# handles1 = [i[0] for i in lis1]
# mPBOList = [1,2, 3,4, 5, 6, 7]
# labels1=[]
# for i in lis1:
# 	label = i[1]
# 	print(label)
# 	ilabel = int(label)
# 	mPBO = mPBOList[ilabel-1]
# 	flabel = label + ' : ' + str(mPBO) + '% '	
# 	labels1.append(flabel)
# leg= ax.legend(handles1,labels1, loc='lower left', frameon=False, ncol = 1, #len(labels1),\
# 	handlelength=4, bbox_to_anchor=(0,0),fontsize=20, title='Group : bike availability',
# 	framealpha=0.5)

# leg.get_title().set_fontsize('20')
# leg.get_title().set_ha('left')
# 	#leg.get_title().set_fontweight('bold')
# leg.get_title().set_color('gray')

# for txt in leg.get_texts():
# 	txt.set_color('gray') #set1[i-1])
# 	txt.set_ha('left')
# 	txt.set_fontweight('bold')
# #txt.set_alpha(0.5)

['modeCar', 'modePT', 'modeBike', 'modeWalk', 'pop', 'popDen','GDPPCP','gasPrice','congest','CO2EmsPC','highwayP']

df = pd.read_csv('../plot-data/urbandata2019-64var-id-sorted-updated-citynames-countries-updated.csv')
#df = df[['clusterID', 'City', 'modeCar', 'modePT', 'modeBike', 'modeWalk']] #'gasPrice','congest','highwayP','

df = df[['clusterID', 'City', 'modeCar', 'modePT', 'modeBike', 'modeWalk', 'pop','popDen','GDPPCP', 'CO2EmsPC','polluI']]
df['pop'] = df['pop']/100000.
df['GDPPCP'] = df['GDPPCP']/1000.
df2 = df
#df2.columns = ['clusterID','City','Car Modeshare', 'PT Modeshare', 'Bike Modeshare', 'Walk Modeshare', 'Population (x 100,000)', 'Population Density (per km2)', 'Per Capita GDP ($1000)', 'CO2 Emissions per capita (metric tonnes p/a)','Pollution Index']

def plot_key_vars(c1, c2):
	df = pd.read_csv('../plot-data/urbandata2019-64var-id-sorted-updated-citynames-countries-updated.csv')
	#df = df[['clusterID', 'City', 'modeCar', 'modePT', 'modeBike', 'modeWalk']] #'gasPrice','congest','highwayP','

	df = df[['clusterID', 'City', 'modeCar', 'modePT', 'modeBike', 'modeWalk', 'pop','popDen','GDPPCP', 'CO2EmsPC','polluI','congest']]
	df['pop'] = df['pop']/100000.
	df['GDPPCP'] = df['GDPPCP']/1000.
	df2 = df
	df.columns = ['clusterID','City','Car Modeshare', 'PT Modeshare', 'Bike Modeshare', 'Walk Modeshare', 'Population (x 100,000)', 'Population Density (per km2)', 'Per Capita GDP ($1000)', 'CO2 Emissions per capita (metric tonnes p/a)','Pollution Index','Congestion']

	df = df.groupby('clusterID').mean()

	df = df.sort_index()
	df.index = clusDict.values()

	if c1 == 11:
		df2 = df.loc[clusDict[c1]]
	else:
		df2 = df.loc[[clusDict[c1],clusDict[c2]]]

	df2 = df2.transpose()
	df2 = df2.round(1)
	df2
	#print(df2)
	df2.plot(kind = 'bar',color = [set1H[c1-1],set1H[c2-1]])
	df2.to_csv('key_vars_{}_{}.csv'.format(c1,c2))
	plt.xticks(rotation=45,ha='right')
	#filepath = dir+file+'.csv'
	# df = pd.read_csv(filepath)
	# for i in np.arange(1,8):
	# 	x =  np.arange(len(df[ind].ix[i]))
	# 	plt.xlabel('Index')	
	# 	plt.scatter(x, df[ind].ix[i], alpha=.6, label = clusDict[i], color=set1H[i-1])
	# 	plt.title(ind)
	plt.show()
"""
plot_key_vars(1,2)
plot_key_vars(3,4)
plot_key_vars(5,6)
plot_key_vars(7,8)
plot_key_vars(9,10)
plot_key_vars(11,12)
"""
