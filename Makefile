SRCDIR := src
OBJDIR := obj
MAIN := $(SRCDIR)/Main.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/STTMRAM.o src/STTMRAM.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/Controller.o src/Controller.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/Refresh.o src/Refresh.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/HBM.o src/HBM.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/MemoryFactory.o src/MemoryFactory.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/Config.o src/Config.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/DDR4.o src/DDR4.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/DDR3.o src/DDR3.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/StatType.o src/StatType.cpp
# g++  -O3 -std=c++11 -g -Wall -DRAMULATOR -c -o obj/PCM.o src/PCM.cpp
SRCF := Controller.cpp Refresh.cpp HBM.cpp MemoryFactory.cpp Config.cpp DDR4.cpp DDR3.cpp StatType.cpp PCM.cpp \
# SRCF += WideIO2.cpp
SRCF += Trace.cpp # Processor.cpp Cache.cpp
SRCS := $(patsubst %.cpp, $(SRCDIR)/%.cpp, $(SRCF))
# SRCS := $(filter-out $(MAIN) $(SRCDIR)/Gem5Wrapper.cpp, $(wildcard $(SRCDIR)/*.cpp))
OBJS := $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SRCS))


# Ramulator currently supports g++ 5.1+ or clang++ 3.4+.  It will NOT work with
#   g++ 4.x due to an internal compiler error when processing lambda functions.
CXX := g++ # clang++
# CXX := g++-5
CXXFLAGS := -O3 -std=c++11 -g -Wall

.PHONY: all clean depend

all: depend ramulator

clean:
	rm -f ramulator
	rm -rf $(OBJDIR)

depend: $(OBJDIR)/.depend


$(OBJDIR)/.depend: $(SRCS)
	@mkdir -p $(OBJDIR)
	@rm -f $(OBJDIR)/.depend
	@$(foreach SRC, $(SRCS), $(CXX) $(CXXFLAGS) -DRAMULATOR -MM -MT $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SRC)) $(SRC) >> $(OBJDIR)/.depend ;)

ifneq ($(MAKECMDGOALS),clean)
-include $(OBJDIR)/.depend
endif


ramulator: $(MAIN) $(OBJS) $(SRCDIR)/*.h | depend
	$(CXX) $(CXXFLAGS) -DRAMULATOR -o $@ $(MAIN) $(OBJS)

libramulator.a: $(OBJS) $(OBJDIR)/Gem5Wrapper.o
	libtool -static -o $@ $(OBJS) $(OBJDIR)/Gem5Wrapper.o

$(OBJS): | $(OBJDIR)

$(OBJDIR):
	@mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -DRAMULATOR -c -o $@ $<
