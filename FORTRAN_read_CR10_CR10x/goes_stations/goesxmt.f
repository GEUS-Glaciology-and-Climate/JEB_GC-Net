      Program gdf

	implicit none
c ---------------------------------------------------------
c     Program to read the variable
c ---------------------------------------------------------

      real swin,swref,NET,Tc(12),
     *  RH1,RH2,U(2),DIR(2),BAR,sd1,sd2,TCS5001,TCS5002,
     * tca(2),m(10),bat,jt,garb

      integer i,k,year,st

      character*2 stnum

	print*,'Input station number (1, 2, 6, 8, 9, 10, 11)'
	read(*,*),st
c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
        OPEN (UNIT=1,FILE='/ice/tools/aws/01/xmt_data/01.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/01ax.dat')
	  stnum='01'
	  year=1998
	endif
c -------------------------------------------------------- GISP2
	if(st.eq.6)then
        OPEN (UNIT=1,FILE='/ice/tools/aws/06/xmt_data/06.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/06ax.dat')
	  stnum='06'
	  year=1998
	endif
c -------------------------------------------------------- DYE-2
	if(st.eq.8)then
        OPEN (UNIT=1,FILE='/ice/tools/aws/08/xmt_data/08.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/08ax.dat')
	  stnum='08'
	  year=1998
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
        OPEN (UNIT=1,FILE='/ice/tools/aws/09/xmt_data/09.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/09ax.dat')
	  stnum='09'
	  year=1998
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/10/xmt_data/10.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/10ax.dat')  
	  stnum='10'
	  year=1998
	endif
c -------------------------------------------------------- SDOME
	if(st.eq.11)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/11/xmt_data/11.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/11ax.dat')
	  stnum='11'
	  year=1998
	endif
c --------------------------------------------------------

	TCS5001=999.
	TCS5002=999.
	bat=999.

	print*,'Begin processing.' 


c --------------------------------------------------------- begin loop
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

c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
          READ(1,*,end=999) jt,NET,garb,
     *    garb,garb,garb,garb,m(1),m(2),m(3),m(4),
     *    TCa(1),TCa(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
     *    sd2,tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),m(5),m(6),m(7),
     *    m(8),bat,garb
	endif
c -------------------------------------------------------- GISP 2
	if(st.eq.6)then
c          READ(1,*,end=999) jt,swin,swref,NET,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    tca(1),tca(2),TCS5001,TCS5002,
c     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd2,sd1,
c     *    m(1),m(2)
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(3),bat
	endif
c -------------------------------------------------------- DYE-2
	if(st.eq.8)then
          READ(1,*,end=999) jt,swin,swref,NET,
     *    Tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    m(5),m(6),TCS5001,TCS5002,bat,
     *    m(1),m(2),m(3),m(4),m(7),m(8),m(9)
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
c	  if((jt.lt.146.75).and.(year.eq.1998))then
c            READ(1,*,end=999) jt,swin,swref,NET,
c     *      tca(1),tca(2),TCS5001,TCS5002,
c     *      RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
c     *      tc(6),tc(7),tc(8),tc(9),tc(10),m(1),m(2),
c     *      m(4),m(3),garb
c	  endif
c	  if((jt.ge.146.75).and.(year.eq.1998))then
            READ(1,*,end=999) jt,swin,swref,NET,
     *      tc(6),tc(7),tc(8),tc(9),tc(10),
     *      tc(1),tc(2),tc(3),tc(4),tc(5),
     *      Tca(1),tca(2),TCS5001,TCS5002,
     *      RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *      m(3),bat
c	  endif
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
          READ(1,*,end=999) jt,swin,swref,NET,
     *    Tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(2),BAR,sd1,sd2,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),garb,
     *    TCS5001,TCS5002,bat
	endif
c -------------------------------------------------------- SDOME
c 	if(st.eq.11)then
c         READ(1,*,end=999) jt,swin,swref,NET,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    Tca(1),tca(2),TCS5001,TCS5002,
c     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
c     *    m(1),m(2),m(3)
c	endif
	if(st.eq.11)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(3),bat
	endif
c ---------------------------------------------------------- Write output
         WRITE (10,10) stnum,year,jt,swin,swref,NET,
     *  TCa(1),TCa(2),
     *  TCS5001,TCS5002,RH1,RH2,U(1),U(2),dir(1),dir(2),BAR,sd1,sd2,
     *  tc(1),tc(2),tc(3),tc(4),tc(5),
     *  tc(6),tc(7),tc(8),tc(9),tc(10),
     *  bat,m(1),m(2),m(3),m(4),m(5),m(6),m(7),m(8),m(9),m(10)

10       FORMAT (a2,1x,i4,1x,f10.4,38F10.3)

8000  CONTINUE

999   print*,'Done processing.',i-1,' lines.' 
	print*,''
	print*,'The output is directed to /ice/tools/aws/temp/' 


      END
