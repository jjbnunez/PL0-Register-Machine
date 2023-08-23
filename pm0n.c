//----------------------------------------------------------------------------
// University of Central Florida
// COP3402 - Fall 2017
// Program Authors: Jonah Yonker, Jorge B Nunez
// Instructor: Euripedes Montagne 
//----------------------------------------------------------------------------
// 	pm0.c
//
// 	This is a P-machine, which is a stack machine with two memory stores: the
// 	"stack," which is organized as a stack and contains the data to be used by
// 	the CPU, and the "code," which is organized as a list and contains the
// 	instructions for the machine. The PM/0 CPU has four registers to handle
// 	the stack and code segments: the base pointer, the stack pointer, the
// 	program counter, and the instruction register. The machine also has a
// 	register file with eight registers.


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define MAX_LEXI_LEVELS 3
#define MAX_CODE_LENGTH 500
#define MAX_STACK_HEIGHT 2000
#define MAX_REGISTERS 8


typedef struct instruct {
	int op;		// opcode
	int r;		// target register
	int l;		// lexicographical level
	int m;		// variable
} instruct;


typedef struct cpu {
	instruct **code;				// list of code
	int ir[4];						// instruction register
	int pc;							// program counter
	int prevpc;						// previous PC for stack trace
	int bp;							// base pointer
	int sp;							// stack pointer
	int caltrace[MAX_LEXI_LEVELS];	// stack frame tracer
	int stack[MAX_STACK_HEIGHT];	// stack
	int regfile[MAX_REGISTERS];		// register file
	int halt;						// halt flag
} cpu;


cpu *init(cpu *pm0, int argc, char **argv)
{
	FILE *ifp, *ofp_op, *ofp_st;
	int idx, buff[4];

	// Check command line parameter count.
	if (argc != 2) {
		fprintf(stderr, "Error: Invalid command line syntax\n");
		fprintf(stderr, "Proper syntax is as follows:\n");
		fprintf(stderr, "Linux: ./pm0 <file>\n");
		fprintf(stderr, "Windows: .\\pm0 <file>\n\n");
		return NULL;
	}
	
	// Check if input file exists.
	ifp = fopen(argv[1], "r");
	if (ifp == NULL) {
		fprintf(stderr, "Error: File I/O exception\n");
		fprintf(stderr, "Could not open \'%s\' for reading\n\n", argv[1]);
		return NULL;
	}

	// Check if opprintout file can be opened/overwritten.
	ofp_op = fopen("opprintout.txt", "w");
	if (ofp_op == NULL) {
		fprintf(stderr, "Error: File I/O exception\n");
		fprintf(stderr, "Could not open \'opprintout.txt\' for writing\n\n");
		return NULL;
	}

	// Check if stacktrace file can be opened/overwritten.
	ofp_st = fopen("stacktrace.txt", "w");
	if (ofp_st == NULL) {
		fprintf(stderr, "Error: File I/O exception\n");
		fprintf(stderr, "Could not open \'stacktrace.txt\' for writing\n\n");
		return NULL;
	} 
	
	// It's now safe to allocate memory and initialize struct fields.
	pm0 = malloc(sizeof(cpu));
	pm0->code = NULL;
	pm0->pc = 0;
	pm0->prevpc = 0;
	pm0->bp = 1;
	pm0->sp = 0;
	pm0->halt = 0;
	for (idx = 0; idx < 4; idx++)
		pm0->ir[idx] = 0;
	for (idx = 0; idx < MAX_STACK_HEIGHT; idx++)
		pm0->stack[idx] = 0;
	for (idx = 0; idx < MAX_LEXI_LEVELS; idx++)
		pm0->caltrace[idx] = -1;
	for (idx = 0; idx < MAX_REGISTERS; idx++)
		pm0->regfile[idx] = 0;
	
	// This is tricky. We're allocating one extra pointer space at the end of
	// the list to always equal NULL. This will let us traverse the list in a
	// "blind" fashion, as running into NULL guarantees we are at the end of
	// the list. Supremely useful! Works like a C string, really.
	pm0->code = malloc(sizeof(instruct*) * (MAX_CODE_LENGTH + 1));
	for (idx = 0; idx < MAX_CODE_LENGTH + 1; idx++) {
		pm0->code[idx] = NULL;
	}
	idx = 0;
	
	// Scan instructions into the CPU's code list.
	while ((fscanf(ifp, "%d", &buff[0]) != EOF) && (idx < MAX_CODE_LENGTH)) {
		fscanf(ifp, "%d", &buff[1]);
		fscanf(ifp, "%d", &buff[2]);
		fscanf(ifp, "%d", &buff[3]);
		pm0->code[idx] = malloc(sizeof(instruct));
		pm0->code[idx]->op = buff[0];
		pm0->code[idx]->r = buff[1];
		pm0->code[idx]->l = buff[2];
		pm0->code[idx]->m = buff[3];
		idx++;
	}
	
	// We're done! Close all files. Return to main.
	fclose(ifp);
	fclose(ofp_op);
	fclose(ofp_st);
	return pm0;
}


cpu *destroyCPU(cpu *pm0)
{
	int idx;
	
	// Free the CPU's code list first. Ignore NULL pointers, free the rest.
	for (idx = MAX_CODE_LENGTH; idx >= 0; idx--) {
		if (pm0->code[idx] == NULL)
			;
		else
			free(pm0->code[idx]);
	}

	// Free the CPU itself. Then return to previous function.
	// Wow, CPU, great moves! Keep it up! Proud of you! 
	free(pm0);
	return NULL;
}


// Helper function provided by homework documentation.
int base(cpu *pm0)
{
	int bl, l;
	bl = pm0->bp;
	l = pm0->ir[2];
	while (l > 0)
	{
		bl = pm0->stack[bl + l];
		l--;
	}
	return bl;
}


char *optostring(int op)
{
	// Malloc necessary, because you can't return a local array.
	char *opc = malloc(sizeof(char) * 4);

	// Assign string to opcode value. Return string.
	switch (op) {
		case 1:
        strcpy(opc, "lit");
		break;
		
		case 2:
		strcpy(opc, "rtn");
        break;

        case 3:
        strcpy(opc, "lod");
        break;

        case 4:
        strcpy(opc, "sto");
        break;

        case 5:
        strcpy(opc, "cal");
        break;

        case 6:
        strcpy(opc, "inc");
        break;

        case 7:
        strcpy(opc, "jmp");
        break;

        case 8:
        strcpy(opc, "jpc");
        break;

		case 9:
        strcpy(opc, "sio");
        break;

        case 10:
        strcpy(opc, "neg");
        break;

        case 11:
        strcpy(opc, "add");
        break;

        case 12:
        strcpy(opc, "sub");
        break;

        case 13:
        strcpy(opc, "mul");
        break;

		case 14:
        strcpy(opc, "div");
        break;

        case 15:
        strcpy(opc, "odd");
        break;

        case 16:
        strcpy(opc, "mod");
        break;

        case 17:
        strcpy(opc, "eql");
        break;

        case 18:
        strcpy(opc, "neq");
        break;

        case 19:
        strcpy(opc, "lss");
        break;

        case 20:
        strcpy(opc, "leq");
        break;

        case 21:
        strcpy(opc, "gtr");
        break;

        case 22:
        strcpy(opc, "geq");
        break;

        default:
        strcpy(opc, "err");
        break;
	}

	// Return string to caller.
	return opc;
}


cpu *opprint(cpu *pm0)
{
	FILE *ofp_op;
	int idx, s[4];
	char *opc;
	
	// Check if opprint.txt file can be opened/appended.
	ofp_op = fopen("opprintout.txt", "a");
	if (ofp_op == NULL) {
		fprintf(stderr, "Error: File I/O exception\n");
		fprintf(stderr, "Could not open \'opprintout.txt\' for append\n\n");
		return destroyCPU(pm0);
	}
	
	// Printout loop
	for (idx = 0; pm0->code[idx] != NULL; idx++) {
		// First, assign instruction values to temporary buffer.
		s[0] = pm0->code[idx]->op;
		s[1] = pm0->code[idx]->r;
		s[2] = pm0->code[idx]->l;
		s[3] = pm0->code[idx]->m;
		
		// Then, assign string value to opcode and check for an invalid code.
		strcpy(opc, optostring(s[0]));
		if (strcmp(opc, "err") == 0) {
			fprintf(stderr, "Error: Invalid opcode exception\n");
			fprintf(stderr, "Code line %d, opcode %d", idx, s[0]);
			return destroyCPU(pm0);
		}
		
		// If all is well, print out to console and to file.
		fprintf(stdout, "%4d %s %d %d %d\n", idx, opc, s[1], s[2], s[3]);
		fprintf(ofp_op, "%4d %s %d %d %d\n", idx, opc, s[1], s[2], s[3]);
		
		// Free malloc'd opcode string to prevent memory leak.
		free(opc);
	}
	
	// Close file when finished! Print a newline and return to main().
	fclose(ofp_op);
	fprintf(stdout, "\n");
	return pm0;
}


cpu *stacktrace(cpu *pm0)
{
	FILE* ofp_st;
	int ln, r, l, m, pc, bp, sp, idx;
	char s[4];
	
	// Check if stacktrace.txt file can be opened/appended.
	ofp_op = fopen("stacktrace.txt", "a");
	if (ofp_op == NULL) {
		fprintf(stderr, "Error: File I/O exception\n");
		fprintf(stderr, "Could not open \'stacktrace.txt\' for append\n\n");
		return destroyCPU(pm0);
	}
	
	ln = pm0->prevpc;
	strcpy(s, optostring(pm0->ir[0]));
	r = pm0->ir[1];
	l = pm0->ir[2];
	m = pm0->ir[3];
	pc = pm0->pc;
	bp = pm0->bp;
	sp = pm0->sp;

	fprintf(stdout, "%d\t%s\t", ln, s);
	fprintf(ofp_st, "%d\t%s\t", ln, s);
	fprintf(stdout, "%d\t%d\t%d\t%d\t%d\t%d\t", r, l, m, pc, bp, sp);
	fprintf(ofp_st, "%d\t%d\t%d\t%d\t%d\t%d\t", r, l, m, pc, bp, sp);
	for (idx = 1; idx <= pm0->sp; idx++) {
		fprintf(stdout, "%d ", pm0->stack[idx]);
		fprintf(ofp_st, "%d ", pm0->stack[idx]);
	}
	fprintf(stdout, "\n");
	fprintf(ofp_st, "\n");
	
	fclose(ofp_st);
	return pm0;
}


cpu *fetch(cpu *pm0)
{
	// Redundant, but keeps things simple.
	int pc = pm0->pc;

	// Check if program counter is within code length.
	if ((pm0->code[pc] == NULL) || (pc < 0) || (pc >= MAX_CODE_LENGTH)) {
		fprintf(stderr, "Error: Invalid program counter value\n");
		fprintf(stderr, "No instruction exists at line %d\n\n", pc);
		return destroyCPU(pm0);
	}

	// Update the instruction record.
	pm0->ir[0] = pm0->code[pc]->op;
	pm0->ir[1] = pm0->code[pc]->r;
	pm0->ir[2] = pm0->code[pc]->l;
	pm0->ir[3] = pm0->code[pc]->m;
	
	// Increment the program counter.
	pm0->prevpc = pm0->pc;
	pm0->pc = pm0->pc + 1;

	return pm0;
}


cpu *execute(cpu *pm0)
{
	int buff;

	// Processes and makes changes as per opcode basis.
	switch (pm0->ir[0]) {
		// LIT
		case 1:
        pm0->regfile[pm0->ir[1]] = pm0->ir[3];
		break;
		
		// RTN
		case 2:
		pm0->sp = pm0->bp - 1;
		pm0->bp = pm0->stack[pm0->sp + 3];
		pm0->pc = pm0->stack[pm0->sp + 4];
        break;

		// LOD
        case 3:
        pm0->regfile[pm0->ir[1]] = pm0->stack[base(pm0) + pm0->ir[3]];
        break;

		// STO
        case 4:
        pm0->stack[base(pm0) + pm0->ir[3]] = pm0->regfile[pm0->ir[1]];
        break;

		// CAL
        case 5:
        pm0->stack[pm0->sp + 1] = 0;
		pm0->stack[pm0->sp + 2] = base(pm0);
		pm0->stack[pm0->sp + 3] = pm0->bp;
		pm0->stack[pm0->sp + 4] = pm0->pc;
		pm0->bp = pm0->sp + 1;
		pm0->pc = pm0->ir[3];
        break;

		// INC
        case 6:
        pm0->sp = pm0->sp + pm0->ir[3];
        break;

		// JMP
        case 7:
        pm0->pc = pm0->ir[3];
        break;

		// JPC
        case 8:
        if (pm0->regfile[pm0->ir[1]] == 0)
			pm0->pc = pm0->ir[3];
		break;

		// SIO
		case 9:
        if (pm0->ir[3] == 1) {
			fprintf(stdout, "Program output: %d\n", pm0->regfile[pm0->ir[1]]);
		}
		else if (pm0->ir[3] == 2) {
			fprintf(stdout, "Program requesting integer input: ");
			fscanf(stdin, "%d", &buff);
			pm0->regfile[pm0->ir[1]] = buff;
		}
		else if (pm0->ir[3] == 3) {
			pm0->pc = 0;
			pm0->bp = 1;
			pm0->sp = 0;
			pm0->halt = 1;
		}
		else {
			fprintf(stderr, "Error: Invalid SIO parameter\n");
			fprintf(stderr, "Cannot process M value %d\n\n", pm0->ir[3]);
			return destroyCPU(pm0);
		}
        break;

		// NEG
        case 10:
		pm0->regfile[pm0->ir[1]] = 0 - pm0->regfile[pm0->ir[2]];
        break;

		// ADD
        case 11:
		pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] +
			pm0->regfile[pm0->ir[3]];
        break;

		// SUB
        case 12:
        pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] -
			pm0->regfile[pm0->ir[3]];
        break;

		// MUL
        case 13:
        pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] *
			pm0->regfile[pm0->ir[3]];
		break;

		// DIV
		case 14:
		pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] /
			pm0->regfile[pm0->ir[3]];
        break;

		// ODD
        case 15:
		pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[1]] % 2;
        break;

		// MOD
        case 16:
		pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] %
			pm0->regfile[pm0->ir[3]];
        break;

		// EQL
        case 17:
        pm0->regfile[pm0->ir[1]] = (pm0->regfile[pm0->ir[2]] ==
			pm0->regfile[pm0->ir[3]]);
        break;

		// NEQ
        case 18:
        pm0->regfile[pm0->ir[1]] = (pm0->regfile[pm0->ir[2]] !=
			pm0->regfile[pm0->ir[3]]);
		break;

		// LSS
        case 19:
        pm0->regfile[pm0->ir[1]] = (pm0->regfile[pm0->ir[2]] <
			pm0->regfile[pm0->ir[3]]);
		break;

		// LEQ
        case 20:
		pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] <=
			pm0->regfile[pm0->ir[3]];
        break;

		// GTR
        case 21:
        pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] >
			pm0->regfile[pm0->ir[3]];
        break;

		// GEQ
        case 22:
		pm0->regfile[pm0->ir[1]] = pm0->regfile[pm0->ir[2]] >=
			pm0->regfile[pm0->ir[3]];
        break;
		
		// ERR
        default:
		fprintf(stderr, "Error: Invalid opcode exception\n");
		fprintf(stderr, "Code line %d, opcode %d", pm0->pc - 1, pm0->ir[0]);
		return destroyCPU(pm0);
		break;
	}

	pm0 = stacktrace(pm0);

	return pm0;
}


int main(int argc, char **argv)
{
	// Initialize the virtual machine.
	cpu *pm0 = init(pm0, argc, argv);
	
	// Check if the machine initialized correctly.
	// If so, print out the instructions passed in as input.
	if (pm0 != NULL) {
		fprintf(stdout, "Op Printout\n");
		pm0 = opprint(pm0);
	}
	
	fprintf(stdout, "\t\t\t\t\tpc\tbp\tsp\tstack\n");
	fprintf(stdout, "Initial Values\t\t\t\t");
	fprintf(stdout, "%d\t%d\t%d\n", pm0->pc, pm0->bp, pm0->sp);

	while ((pm0->halt != 1) && (pm0 != NULL)) {
		pm0 = fetch(pm0);
		
		if (pm0 == NULL)
			break;

		pm0 = execute(pm0);

		if (pm0 == NULL)
			break;
	}

	pm0 = destroyCPU(pm0);

	return 0;
}
