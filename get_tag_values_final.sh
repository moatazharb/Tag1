#!/usr/bin/python 


#get the tag values from the h5m file and print as a list: tag_values
from itaps import iMesh,iBase
import string

datafile = "test_models/test_4.h5m"

mesh = iMesh.Mesh()
mesh.load(datafile)

ents = mesh.getEntities()
print mesh.getEntType(ents)
ents = mesh.getEntities(iBase.Type.all, iMesh.Topology.triangle)
print len(ents)
mesh_set = mesh.getEntSets()
print len(mesh_set)

tag_values=[]
found_all_tags=0
for i in mesh_set:
    if found_all_tags == 1:
	break

    # get all the tags
    tags = mesh.getAllTags(i)
    #print tags
    # loop over the tags checking for name
    for t in tags:
        # if we find name
        if t.name == 'NAME':
	    # the handle is the tag name
	    t_handle = mesh.getTagHandle(t.name)
	    # get the data for the tag, with taghandle in element i
	    tag = t_handle[i]
	    a=[]
	    # since we have a byte type tag loop over the 32 elements
	    for part in tag:
	        # if the byte char code is non 0
                #print part
      	        if (part != 0 ):
		    # convert to ascii 
		    a.append(str(unichr(part)))
		    # join to end string
		    test=''.join(a)
	    # the the string we are testing for is not in the list of found
	    # tag values, add to the list of tag_values
	    if not any(test in s for s in tag_values):
		    tag_values.append(test)
		    #print test
		    # if the tag is called impl_complement, this is the 
		    # last tag we are done
		    if any('impl_complement' in s for s in tag_values):
			    found_all_tags=1 


print('------------------------')
#detecting the material name and density and create a list with 'mat="NAME"' as the key and 'rho=-$.$$' as the stored value.
print('tag_values:')
print tag_values
global list
list=[]
materialdensity={}
for l in range(len(tag_values)) :
    if '/' in tag_values[l] :
        index=tag_values[l].index('/')
        #print tag_values[l][0:index]
        list.append(tag_values[l][0:index])
        a=index+1 
        materialdensity[tag_values[l][0:index]]=tag_values[l][a:len(tag_values[l])]

#print list
newlist=[]
for w in range(len(list)) :
    newlist.append(list[w][4:len(list[w])])
#print len(list)
print materialdensity


# writing the materials provided in a text to mcnp.
from pyne import material
from pyne import mcnp
from pyne.material import Material
global a
global f
a=[]
global materialz
materialz=Material()
matz=Material()
print('materials :')
print newlist


#counting the number of lines in the  material text
def flines(n) :
    global lines
    i=0
    f=open('material2.txt','r')
    a=f.readlines()
    for line in enumerate(a) :
        i=i+1 
    lines = i       
    print('number of lines in the text is: %i' %lines)

flines(1)
#calling flines needs modification!!


matposition={}
for mat in newlist :
    b=open('material2.txt','r')
    for k in range(lines) :
        while mat in b.readline() :
                print mat, (': %i' %k)
                matposition[k]=mat
print matposition
print sorted(matposition.keys())

sortedkeys=sorted(matposition.keys())
x=open('material2.txt','r')
for k in sortedkeys :
    print k
    #f=open('matmcnp.txt','w')
    #x=open('material2.txt','r') 
    for mat in newlist :
        if mat == matposition[k] :
             p=open('matmcnp.txt','w')
             ll=int(k)
             if k == int(sortedkeys[len(sortedkeys)-1]) :
                 ul=lines
             else :   
                 ul=int(sortedkeys[sortedkeys.index(k)+1])
             #print(type(sortedkeys.index(k)+1))
             print ll, ul
             for j in range(ll,ul) :
                 p.write(x.readline())
    p.close()
    materialz.from_text('matmcnp.txt')
    materialz.write_mcnp('txtmcnp.txt',frac_type='mass')

x.close()
'''
problem:
material names in the material text can not occur more than once!!!1
'water' 'and steel and water' caused conflict !!!
    


'''
           
             


  







	     
