
.SUFFIXES: .o .cpp .l

.o: 
	$(CCC) $(CCFLAGS) $(LDFLAGS) -o $@ $<

.cpp: 
	$(CCC) $(CCFLAGS) $(LDFLAGS) -o $@ $<

.l.cpp: 
	$(LEX) $(LFLAGS) --outfile=$@ $<

LEX=flex
CCC=g++

PROGS = f0

all:
	make $(PROGS)

clean:
	rm -f `ls *.l | sed "s/\.l/.cpp/g"` 2>/dev/null
	rm -f $(PROGS) *.o *.exe a.out lex.*.c lex.*.cpp *.dot *.output *.stackdump 

f0.o: f0.cpp
