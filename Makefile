VERSION  = 1.0
CC      ?= cc
AR      ?= ar
CFLAGS  ?= -O2
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
INCDIR  ?= $(PREFIX)/include
LIBDIR  ?= $(PREFIX)/lib
EXTRA_CFLAGS = -I. -Wall -Wextra -fPIC

OBJS = rpmatch.o

SOBASE = librpmatch.so
SONAME = $(SOBASE).0

SLIB = librpmatch.a
DLIB = $(SONAME).0.0

.PHONY: clean

all: $(SLIB) $(DLIB) musl-rpmatch.pc

.c.o:
	$(CC) -c -o $@ $< $(EXTRA_CFLAGS) $(CFLAGS)

$(SLIB): $(OBJS)
	$(AR) -rcs $(SLIB) $(OBJS)

$(DLIB): $(OBJS)
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) $(LDFLAGS) $(OBJS) \
		-shared -Wl,-soname,$(SONAME) -o $(DLIB)

musl-rpmatch.pc: musl-rpmatch.pc.in
	sed -e "s,@prefix@,$(PREFIX)," \
		-e 's,@exec_prefix@,$$\{prefix\},' \
		-e 's,@libdir@,$$\{exec_prefix\}/lib,' \
		-e 's,@includedir@,$$\{prefix\}/include,' \
		-e "s,@VERSION@,$(VERSION)," musl-rpmatch.pc.in > musl-rpmatch.pc

clean:
	rm -f $(OBJS) $(SLIB) $(DLIB) musl-rpmatch.pc

install: $(SLIB) $(DLIB)
	install -d $(DESTDIR)$(LIBDIR)
	install -m 755 $(DLIB) $(DESTDIR)$(LIBDIR)/$(DLIB)
	install -m 644 $(SLIB) $(DESTDIR)$(LIBDIR)/$(SLIB)
	ln -sf $(DLIB) $(DESTDIR)$(LIBDIR)/$(SONAME)
	ln -sf $(DLIB) $(DESTDIR)$(LIBDIR)/$(SOBASE)
	install -d $(DESTDIR)$(INCDIR)
	install -m 644 rpmatch.h $(DESTDIR)$(INCDIR)/rpmatch.h
	install -d $(DESTDIR)$(LIBDIR)/pkgconfig
	install -m 644 musl-rpmatch.pc $(DESTDIR)$(LIBDIR)/pkgconfig/musl-rpmatch.pc
