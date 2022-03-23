        PROGRAM argos3
c                                               Jason E. Box
c program to generate common format from the ARGOS data.
c buffer 1 the next step is to merge the two buffers.
c -----------------------------------------------------------------
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
	print*,''
	print*,''
	print*,'-------------------- Processing station ',stnums(iii)
	st=stnums(iii)

	do buffer=1,2 
	  cc=0
	  ct=0

c ----------------------------------------------------- input files
c ------------------------------------------------------- GITS
	if(st.eq.3)then
	  stnum='03'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/03.2.b1.dat'
	    oup='/ice/tools/aws/temp/03.3.b1.dat'
	    oup2='/ice/tools/aws/temp/nlines03.b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/03.2.b2.dat'
	    oup='/ice/tools/aws/temp/03.3.b2.dat'
	    oup2='/ice/tools/aws/temp/nlines03.b2.dat'
	  endif
	endif
c ------------------------------------------------------- NASA-U
	if(st.eq.4)then
	  stnum='04'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/04.2.b1.dat'
	    oup='/ice/tools/aws/temp/04.3.b1.dat'
	    oup2='/ice/tools/aws/temp/nlines04.b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/04.2.b2.dat'
	    oup='/ice/tools/aws/temp/04.3.b2.dat'
	    oup2='/ice/tools/aws/temp/nlines04.b2.dat'
	  endif
	endif
c ------------------------------------------------------- Humboldt
	if(st.eq.5)then
	  stnum='05'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/05.2.b1.dat'
	    oup='/ice/tools/aws/temp/05.3.b1.dat'
	    oup2='/ice/tools/aws/temp/nlines05.b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/05.2.b2.dat'
	    oup='/ice/tools/aws/temp/05.3.b2.dat'
	    oup2='/ice/tools/aws/temp/nlines05.b2.dat'
	  endif
	endif
c ------------------------------------------------------- TUNU-N
	if(st.eq.7)then
	  stnum='07'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/07.2.b1.dat'
	    oup='/ice/tools/aws/temp/07.3.b1.dat'
	    oup2='/ice/tools/aws/temp/nlines07.b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/07.2.b2.dat'
	    oup='/ice/tools/aws/temp/07.3.b2.dat'
	    oup2='/ice/tools/aws/temp/nlines07.b2.dat'
	  endif
	endif

c ------------------------------------------------------- NASA-E
	if(st.eq.12)then
	  stnum='12'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/12.2.b1.dat'
	    oup='/ice/tools/aws/temp/12.3.b1.dat'
	    oup2='/ice/tools/aws/temp/nlines12.b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/12.2.b2.dat'
	    oup='/ice/tools/aws/temp/12.3.b2.dat'
	    oup2='/ice/tools/aws/temp/nlines12.b2.dat'
	  endif
	endif
c ------------------------------------------------------- NGRIP
	if(st.eq.14)then
	  stnum='14'
	  if (buffer .eq. 1 )then 
	    inp='/ice/tools/aws/temp/14.2.b1.dat'
	    oup='/ice/tools/aws/temp/14.3.b1.dat'
	    oup2='/ice/tools/aws/temp/nlines14.b1.dat'
  	  endif
	  if (buffer .eq. 2 )then 
	    inp='/ice/tools/aws/temp/14.2.b2.dat'
	    oup='/ice/tools/aws/temp/14.3.b2.dat'
	    oup2='/ice/tools/aws/temp/nlines14.b2.dat'
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
	if((st.eq.7).or.(st.eq.3).or.(st.eq.4))then
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
c ----------------------------------------- NGRIP
	if((st.eq.14).or.(st.eq.3))then
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
	if(st.eq.12)then
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
