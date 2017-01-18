### Definitions Section ###

EXECUTABLE = Connect_4
SOURCE_DIR = src
OBJECT_DIR = build

# Define the list of files to compile for this project. Defaults to all
# of the .cpp files in the source directory.
CPPFILES = $(wildcard $(SOURCE_DIR)/*.cpp)

# For each of the .cpp files found above, determine the name of the 
# corresponding .o file to create.
OBJFILES = $(addprefix $(OBJECT_DIR)/,  $(notdir $(CPPFILES:.cpp=.o)))

CC = g++
CFLAGS = -g -c -Wall
LDFLAGS = -g

GLUI_PATH = ./glui
PNG_PATH = $(realpath ./libpng-1.6.16)
INCLUDE += -I$(GLUI_PATH)/include -I$(PNG_PATH)/
LINK_LIBS +=  -L$(GLUI_PATH)/lib/ -lglui -L$(PNG_PATH)/.libs/ -lpng16 -lz -lpthread
GLUI_LIB = $(GLUI_PATH)/lib/libglui.a
PNG_LIB = $(PNG_PATH)/.libs/libpng16.a

# For graphics support, we also need to link with the Glut and OpenGL libraries.
# This is specified differently depending on whether we are on linux or OSX.
UNAME = $(shell uname)
ifeq ($(UNAME), Darwin) # Mac OSX 
	LINK_LIBS += -framework glut -framework opengl

else # LINUX 
	ifeq ($(UNAME), Linux)
		LINK_LIBS += -lglut -lGL -lGLU

	else # WINDOWS 
		GLUTINCLUDEPATH = C:\Dev-Cpp\mingw32\freeglut\include\
		GLUTLIBPATH = C:\Dev-Cpp\mingw32\freeglut\lib\
		LINK_LIBS += -L$(GLUTLIBPATH) -lfreeglut -lopengl32 -Wl,--subsystem,windows
		INCLUDE += -I$(GLUTPATH)
		EXECUTABLE = BreakOut.exe

	endif
endif

# On some lab machines the glut and opengl libraries are located in the directory
# where the nvidia graphics driver was installed rather than the default /usr/lib
# directory.  In this case, we need to tell the linker to search this nvidia directory
# for libraries as well.
ifneq ($(NVIDIA_LIB), )
	LINK_LIBS += -L$(NVIDIA_LIB)
endif



### Rules Section ###

all: setup $(EXECUTABLE)

rebuild: clean all

# Create the object_files directory only if it does not exist. 
setup: | $(OBJECT_DIR)

$(OBJECT_DIR): 
	mkdir -p $(OBJECT_DIR)

$(EXECUTABLE): $(PNG_LIB) $(OBJFILES) $(GLUI_LIB) 
	$(CC) $(LDFLAGS) $(OBJFILES) $(LINK_LIBS) -o $@

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	$(CC) $(CFLAGS) $(INCLUDE)  -o $@ $<

clean:
	\rm -rf $(OBJECT_DIR) $(EXECUTABLE) 

$(GLUI_LIB): 
	$(MAKE) -C $(GLUI_PATH) all

$(PNG_LIB):
	cd $(PNG_PATH); ./configure --prefix=$(PNG_PATH) --enable-shared=no
	$(MAKE) -C $(PNG_PATH)

