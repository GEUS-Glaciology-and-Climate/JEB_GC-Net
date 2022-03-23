c                                               Jason E. Box
c program to generate common format from the ARGOS data.
c buffer 1
c the next step is to merge the two buffers.
c -----------------------------------------------------------------
        PROGRAM gdf
      implicit none

	integer nstations

	parameter (nstations=6)

	real swin,swref,NET,Tc(12),
     *   RH1,RH2,U(2),DIR(2),BAR,sd1,sd2,TCS5001,TCS5002,
     *   tca(2),m(10),bat,jt,garb

	integer i,k,ct,year,hrmn,fag,cc,buffer,st,buffer,
     *    stnums(nstations),iii,nstations

	character*2 stnum
	character*40 inp,oup,oup2

	data (stnums(i),i=1,nstations)/3,4,5,7,12,14/

	do iii=1,nstations

	print*,'Processing station ',stnums(iii)
	st=stnums(iii)

	do buffer=1,2 
	  cc=0
	  ct=0

c ----------------------------------------------------- input files
c ------------------------------------------------------- GITS
	if(st.eq.3)then
	  stnum='03'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/03.datx'
	    oup='/ice/tools/aws/temp/03b1.datx'
	    oup2='/ice/tools/aws/temp/nlines03.datx'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/03t.datx'
	    oup='/ice/tools/aws/temp/03b2.datx'
	    oup2='/ice/tools/aws/temp/nlines03b2.datx'
	  endif
	endif
c ------------------------------------------------------- NASA-U
	if(st.eq.4)then
	  stnum='04'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/04.datx'
	    oup='/ice/tools/aws/temp/04b1.datx'
	    oup2='/ice/tools/aws/temp/nlines04.datx'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/04t.datx'
	    oup='/ice/tools/aws/temp/04b2.datx'
	    oup2='/ice/tools/aws/temp/nlines04b2.datx'
	  endif
	endif
c ------------------------------------------------------- Humboldt
	if(st.eq.5)then
	  stnum='05'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/05.datx'
	    oup='/ice/tools/aws/temp/05b1.datx'
	    oup2='/ice/tools/aws/temp/nlines05.datx'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/05t.datx'
	    oup='/ice/tools/aws/temp/05b2.datx'
	    oup2='/ice/tools/aws/temp/nlines05b2.datx'
	  endif
	endif
c ------------------------------------------------------- TUNU-N
	if(st.eq.7)then
	  stnum='07'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/07.datx'
	    oup='/ice/tools/aws/temp/07b1.datx'
	    oup2='/ice/tools/aws/temp/nlines07.datx'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/07t.datx'
	    oup='/ice/tools/aws/temp/07b2.datx'
	    oup2='/ice/tools/aws/temp/nlines07b2.datx'
	  endif
	endif
c ------------------------------------------------------- DYE-2
	if(st.eq.8)then
	  stnum='08'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/08.datx'
	    oup='/ice/tools/aws/temp/08b1.dat'
	    oup2='/ice/tools/aws/08/temp/08_n_b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/08t.dat'
	    oup='/ice/tools/aws/temp/08b2.dat'
	    oup2='/ice/tools/aws/08/temp/08_n_b2.dat'
	  endif
	endif
c ------------------------------------------------------- NASA-E
	if(st.eq.12)then
	  stnum='12'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/12.datx'
	    oup='/ice/tools/aws/temp/12b1.datx'
	    oup2='/ice/tools/aws/temp/nlines12.datx'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/12t.datx'
	    oup='/ice/tools/aws/temp/12b2.datx'
	    oup2='/ice/tools/aws/temp/nlines12b2.datx'
	  endif
	endif
c ------------------------------------------------------- NGRIP
	if(st.eq.14)then
	  stnum='14'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/14.datx'
	    oup='/ice/tools/aws/temp/14b1.datx'
	    oup2='/ice/tools/aws/temp/nlines14.datx'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/14t.datx'
	    oup='/ice/tools/aws/temp/14b2.datx'
	    oup2='/ice/tools/aws/temp/nlines14b2.datx'
	  endif
	endif
c -----------------------------------------------------------------
	  print*,'Input is : ',inp
	  print*,'Output is : ',oup
	  print*,'Number of lines in buffer is output to : ',oup2

	  OPEN (UNIT=1,FILE=inp)
          OPEN (UNIT=10,FILE=oup)
          OPEN (UNIT=11,FILE=oup2)

	print*,''
	print*,'Begin processing data.'

	TCS5001=999.
	TCS5002=999.
	bat=999.
	swin=999.
	swref=999.
	net=999.

        DO 8000 I=1,50000

	  do k=1,12
	    tc(k)=999.
	  enddo

 	  do k=1,2
	    tca(k)=999.
	    dir(k)=999.
	    U(k)=999.
	  enddo

 	  do k=1,10
	    m(k)=999.
	  enddo


c ----------------------------------------- standard AWS ARGOS
	if((st.eq.7).or.(st.eq.4))then
	if (buffer .eq. 1) then
          READ(1,*,end=999) jt,hrmn,swin,swref,NET,
     *    tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2
	endif

	if (buffer .eq. 2) then
          READ(1,*,end=999) jt,hrmn,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    TCS5001,TCS5002,m(1),bat
	endif

	endif

	if(st.eq.3)then
	if (buffer .eq. 1) then
          READ(1,*,end=999) jt,hrmn,swin,swref,NET,
     *    tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(2),BAR,sd1,sd2,m(3)
	endif

	if (buffer .eq. 2) then
          READ(1,*,end=999) jt,hrmn,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    TCS5001,TCS5002,dir(1),m(4)
	endif
	endif

	if(st.eq.5)then
	if (buffer .eq. 1) then
          READ(1,*,end=999) jt,hrmn,swin,swref,NET,
     *    tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(2),BAR,sd1,sd2,tc(10)
	endif

	if (buffer .eq. 2) then
          READ(1,*,end=999) jt,hrmn,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    TCS5001,TCS5002,dir(1),garb
	endif
	endif

c ------------------------------------------ DYE-2
	if(st.eq.8)then
	if (buffer .eq. 1) then
          READ(1,*,end=999) jt,hrmn,swin,swref,NET,
     *    tca(1),tca(2),
     *    RH1,RH2,U(2),dir(2),BAR,sd1,sd2,m(1),m(2)
	endif

	if (buffer .eq. 2) then
          READ(1,*,end=999) jt,hrmn,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    TCS5001,TCS5002,m(3),bat
	endif
	endif
c ----------------------------------------- NGRIP, NASA-U, and NASA-E
	if((st.eq.14).or.(st.eq.12))then
	if (buffer .eq. 1) then
          READ(1,*,end=999) jt,hrmn,swin,swref,NET,
     *    tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2
	endif

	if (buffer .eq. 2) then
          READ(1,*,end=999) jt,hrmn,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    TCS5001,TCS5002,m(3),bat
	endif
	endif
c	if(st.eq.12)then
c	if (buffer .eq. 1) then
c          READ(1,*,end=999) jt,hrmn,swin,swref,NET,
c     *    tca(1),tca(2),
c     *    RH1,RH2,U(1),u(2),dir(2),BAR,sd1,sd2,tc(10)
c	endif

c	if (buffer .eq. 2) then
c          READ(1,*,end=999) jt,hrmn,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    TCS5001,TCS5002,dir(1),bat
c	endif
c	endif
c ---------------------------------------------------
	fag=0

	do k=100.,2300.,100.
          if (hrmn.eq.k) fag=1
	enddo

	if (fag.eq.0)ct=ct+1

	if (fag.eq.1) then
          WRITE (10,10) stnum,year,jt,swin,swref,NET,
     *      TCa(1),TCa(2),
     *      TCS5001,TCS5002,RH1,RH2,U(1),U(2),dir(1),dir(2),
     *      BAR,sd1,sd2,
     *      tc(1),tc(2),tc(3),tc(4),tc(5),
     *      tc(6),tc(7),tc(8),tc(9),tc(10),bat,
     *      m(1),m(2),m(3),m(4),m(5),m(6),m(7),m(8),m(9),m(10)

10          FORMAT (a2,1x,i4,1x,f10.4,37F10.3)
	  cc=cc+1
	endif

8000  CONTINUE

999   print*,'Done writting.',cc,' lines to :' 
	  print*,oup2

	write(11,11)  int(cc)
11	format (i5)

	print*,''
        print*,'Number of bogus time values : ',ct
	print*,''

876	continue

	close(1)
	close(10)
	close(11)

        print*, 'Done writting ',oup
	print*,''

	enddo

	enddo

      END
