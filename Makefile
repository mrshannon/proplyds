SRCDIR=src
BINDIR=bin
OBJDIR=$(SRCDIR)

#TO ADD A NEW OUTPUT BINARY...
#  add its name to BINS
#  add a variable listing its objects (see OMAIN, MAIN_OBJECTS)
#  copy the $(BINDIR)/main target, replacing main with your output, and its
#    prereqs with your variable listing objects.
BINS=main treedemo proplyds

OMAIN=main.o gl1util.o scenenode.o heightmap.o sciurus/sciurus.o \
        sciurus/window.o sciurus/keyboard.o sciurus/shaderprogram.o \
        sciurus/shader.o
MAIN_OBJECTS=$(OMAIN:%=$(OBJDIR)/%)

OTREEDEMO=treedemo.o gl1util.o scenenode.o heightmap.o sciurus/sciurus.o \
          sciurus/window.o sciurus/keyboard.o sciurus/glm.o sciurus/dlist.o \
          sciurus/octree.o
TREEDEMO_OBJECTS=$(OTREEDEMO:%=$(OBJDIR)/%)

OPROPLYDS=proplyds.o gl1util.o scenenode.o heightmap.o sciurus/sciurus.o \
        sciurus/window.o sciurus/keyboard.o sciurus/shaderprogram.o \
        sciurus/shader.o
PROPLYDS_OBJECTS=$(OPROPLYDS:%=$(OBJDIR)/%)

OUTPUTS=$(BINS:%=$(BINDIR)/%)

LOCAL_INCLUDES=-I$(SRCDIR)
SDL_LIBS=-lSDL2
BULLET_INCLUDES=-I/usr/include/bullet
BULLET_LIBS=-lBulletDynamics -lBulletCollision -lLinearMath
GL_LIBS=-lGL -lGLU -lXxf86vm -lGLEW
ASSIMP_LIBS=-lassimp
SOIL_LIBS=-lSOIL
LIBS=$(BULLET_LIBS) $(SDL_LIBS) $(GL_LIBS) $(ASSIMP_LIBS) $(SOIL_LIBS)
INCLUDES=$(LOCAL_INCLUDES) $(BULLET_INCLUDES)

STANDARDS=-Wall
#BUILDTYPE=-O3
BUILDTYPE=-g
BUILDPARAM=$(STANDARDS) $(BUILDTYPE)

CFLAGS=$(BUILDPARAM) $(INCLUDES)
LDFLAGS=$(BUILDPARAM) $(LIBS)
#BFLAGS is used when doing compilation and linking in a single step
BFLAGS=$(BUILDPARAM) $(INCLUDES) $(LIBS)

all: $(OUTPUTS) main treedemo proplyds

bin:
	@echo -e '\e[33mCREATING DIRECTORY \e[96m$@\e[m'
	mkdir bin

%: $(BINDIR)/%
	@echo -e '\e[33mSYMLINK \e[96m$@\e[m \e[33mTO \e[94m$^\e[m'
	ln -s $^

$(BINDIR)/main: $(MAIN_OBJECTS) | bin
	@echo -e '\e[33mLINKING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	$(CXX) $^ $(LDFLAGS) -o $@

$(BINDIR)/treedemo: $(TREEDEMO_OBJECTS) | bin
	@echo -e '\e[33mLINKING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	$(CXX) $^ $(LDFLAGS) -o $@

$(BINDIR)/proplyds: $(PROPLYDS_OBJECTS) | bin
	@echo -e '\e[33mLINKING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	$(CXX) $^ $(LDFLAGS) -o $@
	
$(OBJDIR)/%.o:$(SRCDIR)/%.cpp
	@echo -e '\e[33mCOMPILING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	$(CXX) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o:$(SRCDIR)/%.c
	@echo -e '\e[33mCOMPILING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	gcc -Wall -Wextra -pedantic -std=c11 -c $< -o $@

packs: media.zip win3pdeps.zip

media.zip: media
	@echo -e '\e[33mCOMPRESSING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	zip -r $@ $^

win3pdeps.zip: bin32 bin64 3p
	@echo -e '\e[33mCOMPRESSING \e[96m$@\e[m \e[33mFROM \e[94m$^\e[m'
	zip -r $@ $^

clean:
	@echo -e '\e[33mCLEANING...\e[m'
	rm -f -v *~ $(MAIN_OBJECTS) $(TREEDEMO_OBJECTS) $(PROPLYDS_OBJECTS)

clobber: clean
	rm -f -v *~ $(OUTPUTS) main treedemo proplyds media.zip win3pdeps.zip

clean-windows:
	@echo -e '\e[33mCLEANING \e[96mproplyds*\e[m \e[33mFROM \e[94mbin32\e[m'
	rm -rfv bin32/proplyds*
	@echo -e '\e[33mCLEANING \e[96mproplyds*\e[m \e[33mFROM \e[94mbin64\e[m'
	rm -rfv bin64/proplyds*

