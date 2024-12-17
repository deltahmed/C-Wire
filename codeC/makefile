CC = gcc
CFLAGS = -Wall -Wextra
LIBS = -lm
SRCDIR = src
INCDIR = include

SRCS = $(wildcard $(SRCDIR)/*.c)
OBJS = $(SRCS:$(SRCDIR)/%.c=%.o)
TARGET = CWIRE_C


all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LIBS)
	rm -f $(OBJS)

%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@ -I$(INCDIR)

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)
