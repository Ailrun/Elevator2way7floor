VER = iverilog
VERFLAGS = ""
SRCS != find -name "*.vh" | xargs basename -a
OBJS = $(SRCS:%.vh=%.o)

.PHONY : all clean

%.o : %.vh
	$(VER) $(VERFLAGS) $< -o $@

all : OBJS

clean :
	echo $(SRCS)
	echo $(OBJS)
	rm -f $(OBJS)
	rm -f *~
