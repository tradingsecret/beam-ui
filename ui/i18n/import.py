import os, sys, shutil

print(str(sys.argv))
sourceDir = sys.argv[1]
destDir = sys.argv[2]

names = {}



dirs = os.listdir(sourceDir)

for d in dirs:
	if d in names:
		spath = sourceDir + "/" + d + "/en_US.ts"
		print(spath)
		dpath = destDir + "/" + names[d] + ".ts"
		print(dpath)
		shutil.copyfile(spath, dpath)


