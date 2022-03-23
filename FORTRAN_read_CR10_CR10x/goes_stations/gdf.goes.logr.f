      Program gdf

	implicit none
c ---------------------------------------------------------
c     Program to read the variable
c ---------------------------------------------------------

      real swin,swref,NET,Tc(12),
     *  RH1,RH2,U(2),DIR(2),BAR,sd1,sd2,TCS5001,TCS5002,
     * tca(2),m(10),bat,jt,garb

      integer i,k,year,st,kc,jd,hrmn,yr1,yr2,yrchng1,yrchng2,
     * iyear

      character*2 stnum
	print*,''
	print*,' GDF.GOES.LOGR'
	print*,' a FORTRAN program to convert raw data logger data'
	print*,' into the common GDF format.'
	print*,''
	print*,'  Input station number (1,2,6,8,9,10,11,13,15,[16,17,18])'
	read(*,*),st
	print*,'  Input starting year (i.e. 1997)'
	read(*,*),yr1
	print*,'  Input ending year (i.e. 1998)'
	read(*,*),yr2
	if (yr2-yr1 .eq. 1)then
	print*,'  Input the line number at which the new year '
	print*,'begins (i.e. 4322)'
	read(*,*),yrchng1
        yrchng2=99999
	endif
	if (yr2-yr1 .eq. 2)then
	print*,'  Input the line number at which the second year '
	print*,'begins (i.e. 2342)'
	read(*,*),yrchng1
	print*,'  Input the line number at which the third year '
	print*,'begins (i.e. 2342)'
	read(*,*),yrchng2
	endif
	iyear=yr1
c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
c        OPEN (UNIT=1,FILE='/ice/tools/aws/01/dat_logr/awssws9798.dat')
        OPEN (UNIT=1,FILE='/ice/tools/aws/01/dat_logr/tow98-99.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/01ax.dat')
	  stnum='01'
	  year=1998
	endif
c -------------------------------------------------------- Crawford Pt. 1
	if(st.eq.2)then
c        OPEN (UNIT=1,FILE='/ice/tools/aws/02/dat_logr/awscp199.dat')
        OPEN (UNIT=1,FILE='/ice/tools/aws/02/dat_logr/cp1_99.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/02ax.dat')
	  stnum='02'
	  year=1999
	endif
c -------------------------------------------------------- GISP2
	if(st.eq.6)then
        OPEN (UNIT=1,FILE='/ice/tools/aws/06/dat_logr/awssum99.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/06ax.dat')
	  stnum='06'
	  year=1998
	endif
c -------------------------------------------------------- DYE-2
	if(st.eq.8)then
c        OPEN (UNIT=1,FILE='/ice/tools/aws/08/dat_logr/awsdy298.dat')
c        OPEN (UNIT=1,FILE='/ice/tools/aws/08/dat_logr/dy2cal98.dat')
        OPEN (UNIT=1,FILE='/ice/tools/aws/08/dat_logr/awsdy299.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/08ax.dat')
	  stnum='08'
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
c       OPEN (UNIT=1,FILE='/ice/tools/aws/09/dat_logr/jar96-98.dat')
       OPEN (UNIT=1,FILE='/ice/tools/aws/09/dat_logr/awsjar99.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/09ax.dat')
	  stnum='09'
	  year=1998
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/10/dat_logr/awssdl99.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/10ax.dat')  
	  stnum='10'
	  year=1998
	endif
c -------------------------------------------------------- SDOME
	if(st.eq.11)then
c          OPEN (UNIT=1,FILE='/ice/tools/aws/11/dat_logr/awssdm99.dat')
          OPEN (UNIT=1,FILE='/ice/tools/aws/11/dat_logr/sdm99.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/11ax.dat')
	  stnum='11'
	  year=1998
	endif
c -------------------------------------------------------- CP2
	if(st.eq.13)then
c       OPEN (UNIT=1,FILE='/ice/tools/aws/13/dat_logr/cp2_97-8.dat')
c       OPEN (UNIT=1,FILE='/ice/tools/aws/13/dat_logr/cp2init.dat')
       OPEN (UNIT=1,FILE='/ice/tools/aws/13/dat_logr/awscp299.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/13ax.dat')
	  stnum='13'
	  year=1997
	endif
c -------------------------------------------------------- NASA-SE
	if(st.eq.15)then
       OPEN (UNIT=1,FILE='/ice/tools/aws/15/dat_logr/awsnse99.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/15ax.dat')
	  stnum='15'
	  year=1998
	endif
c --------------------------------------------------------

	TCS5001=999.
	TCS5002=999.
	bat=999.

	print*,'Begin processing.' 

	year=yr1

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

	if (i.eq.yrchng1)year=iyear+1
	if (i.eq.yrchng2)year=iyear+2
c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
c          READ(1,*,end=999) kc,jd,hrmn,NET,garb,
c     *    garb,garb,garb,garb,m(1),m(2),m(3),m(4),
c     *    TCa(1),TCa(2),TCS5001,TCS5002,
c     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd2,
c     *    sd1,tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),m(5),m(6),m(7),
c     *    m(8),bat
c tow98-99.dat
          READ(1,*,end=999) kc,year,jd,hrmn,swin,swref,NET,
     *    TCS5001,TCS5002,RH1,RH2,U(1),u(2),
     *    garb,garb,garb,garb,garb,m(6),
     *    garb,garb,garb,garb,garb,garb,
     *    dir(1),dir(2)
	endif

c -------------------------------------------------------- CP1
c awscp199.dat?
c cp199.dat
	if(st.eq.2)then
          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,m(2),
     *    bat
	endif
c -------------------------------------------------------- Summit
	if(st.eq.6)then
c awssum98.dat
c          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
c     *    tca(1),tca(2),
c     *    RH1,RH2,U(1),u(2),dir(2),BAR,sd2,sd1,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    TCS5001,TCS5002,
c     *    garb,garb,garb,garb,garb,garb,garb,garb,garb,garb,
c     *    bat,m(4),m(3)
c awssum99.dat
               READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
     *    sd2,m(2),m(1)
	endif
c -------------------------------------------------------- DYE-2
	if(st.eq.8)then
          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    Tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    m(5),m(6),TCS5001,TCS5002,bat,
     *    m(1),m(2),m(3),m(4),m(7),m(8),m(9)
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
c jar96-98.dat
c          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
c     *    tca(1),tca(2),TCS5001,TCS5002,
c     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),m(1),m(2),
c     *    m(4),m(3)
c  awsjar99.dat
               READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
     *    sd2,m(2),m(1)
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,garb,
     *    bat
	endif
c -------------------------------------------------------- SDOME
 	if(st.eq.11)then
c awssdm99.dat
         READ(1,*,end=999)  kc,jd,hrmn,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(2),m(1)
	endif
c -------------------------------------------------------- CP2
 	if(st.eq.13)then
c         READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
c     *   Tca(1),tca(2),
c     *   RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    TCS5001,TCS5002,bat
c         READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
c     *   Tca(1),tca(2),
c     *   RH1,RH2,U(1),u(2),dir(2),BAR,sd1,sd2,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    TCS5001,TCS5002,bat
c awscp299.dat
         READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *   Tca(1),tca(2),
     *   RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd2,sd1,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    TCS5001,TCS5002,bat
	endif
c -------------------------------------------------------- NASA-SE
 	if(st.eq.15)then
c awsnse99.dat
          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,garb,
     *    bat
	endif
c ---------------------------------------------------------- Write output
	jt=(jd*1.)+(hrmn/2400.)

	print*,i,year,jt

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


      END
