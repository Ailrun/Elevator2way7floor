VER = iverilog
VERFLAGS = ""
SRCS != find -name "*.v" | xargs basename -a
OBJS = $(SRCS:%.v=%.o)

.PHONY : all clean

%.o : %.vh
	$(VER) $(VERFLAGS) $< -o $@

all : OBJS

clean :
	rm -f $(OBJS)
	rm -f *~
