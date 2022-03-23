c                                               Jason E. Box
c general program to convert data logger stored goes station
c data to common format.
c Last modified: 07/27/1998
c -----------------------------------------------------------------
        PROGRAM cdf
      implicit none

      integer i,k,kc,year,hrmn,jd,st,iyear,yrchng
      real swin,swref,NET,Tc(12),
     *  RH1,RH2,U(2),DIR(2),BAR,sd1,sd2,TCS5001,TCS5002,
     * tca(2),m(10),bat,garb,jt

	character*2 stnum

c -----------------------------------------------------------------


	print*,'Input station number. (1, 6, 8, 9, 10, 11, or 13)'
	read(*,*),st
	print*,'Input starting year of 2 year dataset'
	read(*,*),iyear

	print*,''
	print*,'Begin processing data.'

c -------------------------------------------------------- Saddle
	if(st.eq.10)then
	  stnum='10'
	  if(iyear.eq.1997) then
	    yrchng=6127
        OPEN (UNIT=1,FILE='/ice/tools/aws/10/dat_logr/awssdl98.dat')
        OPEN (UNIT=10,FILE='/ice/tools/aws/temp/10ax.dat')
	  endif
	endif

	year=iyear

	TCS5001=999.
	TCS5002=999.
	bat=999.
	garb=999.

        DO 8000 I=1,50000


	if (i .ge. yrchng) year=iyear+1

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


c -------------------------------------------------------- Saddle
	if(st.eq.10)then
          READ(1,*,end=999) kc,jd,hrmn,swin,swref,NET,
     *    Tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(2),BAR,sd1,sd2,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),garb,
     *    TCS5001,TCS5002,bat
	endif

	  jt=jd+(hrmn/2400.)

         WRITE (10,10) stnum,year,jt,swin,swref,NET,
     *  TCa(1),TCa(2),
     *  TCS5001,TCS5002,RH1,RH2,U(1),U(2),dir(1),dir(2),BAR-400,sd1,sd2,
     *  tc(1),tc(2),tc(3),tc(4),tc(5),
     *  tc(6),tc(7),tc(8),tc(9),tc(10),
     *  bat,m(1),m(2),m(3),m(4),m(5),m(6),m(7),m(8),m(9),m(10)

10       FORMAT (a2,1x,i4,1x,f10.4,38F10.3)

8000  CONTINUE

999   print*,'Done processing.',i-1,' lines.' 
	print*,''

876	continue

      END
