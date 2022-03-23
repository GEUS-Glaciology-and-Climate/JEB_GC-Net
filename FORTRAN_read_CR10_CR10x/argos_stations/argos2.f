      Program ARGOS2

c                                               Jason E. Box
c program to split data into 2 buffers
c -----------------------------------------------------------------

      implicit none

	integer nstations
      	real in(24,45000),b1(16,45000),b2(16,45000),a(16),sum,seed,today

	parameter (nstations=6)

      	integer n,c1,c2,st,stnums(nstations),flag,beg,iii,i,
     * nvars,nlines,kkk,jj,kk,j,k,l

      	character*52 input1,input2,input3 

	data (stnums(i),i=1,nstations)/3,4,5,7,12,14/

	print*,''
	print*,'ARGOS 2 batch process all GC-Net AWS for a given year.'
	print*,''
	print*,'This Program separates buffer 1 and 2 from ARGOS transmissions.'
	print*,'Program to read ARGOS data file created by argos1.f'
	print*,'J Box , T. Demaria, and K. Steffen, version 1996-1999'
	print*,''

	nvars=16

	do iii=1,nstations

	print*,'Processing station ',stnums(iii)
	st=stnums(iii)
c ------------------------------------------------------- GITS
	if(st.eq.3)then 
          input1='/ice/tools/aws/temp/03.1.dat'
          input2='/ice/tools/aws/temp/03.2.b2.dat'
          input3='/ice/tools/aws/temp/03.2.b1.dat'
	endif
c ------------------------------------------------------- NASA-U
	if(st.eq.4)then 
          input1='/ice/tools/aws/temp/04.1.dat'
          input2='/ice/tools/aws/temp/04.2.b2.dat'
          input3='/ice/tools/aws/temp/04.2.b1.dat'
	endif
c ------------------------------------------------------- Humboldt
	if(st.eq.5)then 
          input1='/ice/tools/aws/temp/05.1.dat'
          input2='/ice/tools/aws/temp/05.2.b2.dat'
          input3='/ice/tools/aws/temp/05.2.b1.dat'
	endif
c ------------------------------------------------------- TUNU-N
	if(st.eq.7)then 
	  input1='/ice/tools/aws/temp/07.1.dat'
	  input2='/ice/tools/aws/temp/07.2.b2.dat'
	  input3='/ice/tools/aws/temp/07.2.b1.dat'
	endif
c ------------------------------------------------------- NASA E
	if(st.eq.12)then 
	  input1='/ice/tools/aws/temp/12.1.dat'
	  input2='/ice/tools/aws/temp/12.2.b2.dat'  
	  input3='/ice/tools/aws/temp/12.2.b1.dat'
	endif
c ------------------------------------------------------- NGRIP
	if(st.eq.14)then 
	  input1='/ice/tools/aws/temp/14.1.dat'
	  input2='/ice/tools/aws/temp/14.2.b2.dat'  
	  input3='/ice/tools/aws/temp/14.2.b1.dat'
	endif

        print*, 'Begin reading ',input1

      OPEN (1,FILE=input1)
      OPEN (2,FILE=input2)
      OPEN (3,FILE=input3)
	open(4,file='/ice/tools/aws/temp/todays_julian_date.dat')
	read(4,*) today
	close (4)
C     input data from tunu.out produced by argos.for 


      n=0
      c1=0
      c2=0
      nlines=45000


      do 10 i=1,nlines
      read(1,*,end=5001) (in(kkk,i),kkk=1,24)
 	n=n+1
	sum=0.
	do jj=11,20
	  if ((in(jj,i).gt.-100.).and.(in(jj,i).lt.0.)) sum=sum+1
	  if (in(jj,i).eq.-6999.) sum=sum+1
	enddo

c ---------------------- buffer 1 if less than or equal to 4 negative values
        if (sum.le.4) then 
	  c2=c2+1
	  b2(1,c2)=in(9,i)+(in(10,i)/2400.)
	  do jj=2,nvars
	    b2(jj,c2)=in(jj+8,i)
	  enddo
	endif
c --------------------------------- buffer 2 if more than 4 negative values 
        if (sum.gt.4) then 
	  c1=c1+1
	  b1(1,c1)=in(9,i)+(in(10,i)/2400.)
	  do jj=2,nvars
	    b1(jj,c1)=in(jj+8,i)
	  enddo
	endif

   10 continue  
 5001 continue 

	if(c1.eq.0) goto 9999
c ---------------------------------------------------------- Sort buffer 1
c	sort the data with increasing jd_h

	print*,'Begin sorting buffer 1.'

	kk=0
	n=c1

      do 50 j=kk,n
        do 60 l=1,nvars
          a(l)=b1(l,j)
60      continue

        do 61 i=j-1,1,-1
          if(b1(1,i).le.a(1)) goto 62
          do 63 l=1,nvars
            b1(l,i+1)=b1(l,i)
63	  continue
61	continue

        i=0

62	  do 65 l=1,nvars
	    b1(l,i+1)=a(l)
65	  continue       

	  kk=kk+1
50	continue

	print*,'End sorting buffer 1.'

c ---------------------------------------------------------- Sort buffer 2
c	sort the data with increasing jd_h

	print*,'Begin sorting buffer 2.'

	kk=0
	n=c2

      do j=kk,n
        do l=1,nvars
          a(l)=b2(l,j)
	enddo
        do i=j-1,1,-1
          if(b2(1,i).le.a(1)) goto 620
          do l=1,nvars
            b2(l,i+1)=b2(l,i)
	  enddo
	enddo

        i=0

620	  do l=1,nvars
	    b2(l,i+1)=a(l)
	  enddo
	  kk=kk+1
	enddo

	print*,'End sorting buffer 2.'

c ---------------------------------------------- find common time
	beg=1
332	seed=b2(1,beg)
	flag=0

	do i=1,c1
	  if(b1(1,i).eq.seed)flag=1
	enddo
	if (flag.eq.0)then 
	  beg=beg+1
c	  print*,seed,beg
	  goto 332
	endif
c ---------------------------------------------- write out
	flag=0

	do i=1,c1
	  if((b1(1,i).eq.seed).and.(flag.eq.0))then
	    write(2,2) (b1(k,i),k=1,nvars)
	    flag=1
	  endif
	  if (flag.eq.1)then
	    if(b1(1,i).ne.seed) then
	    if(b1(1,i).ne.b1(1,i-1)) then
c	      if((b1(1,i).ge.today-10.).and.(b1(1,i).lt.today)) then
	      if(b1(1,i).lt.today+0.5) then
c	print*,b1(0,i),b1(1,i)
	        write(2,2) (b1(k,i),k=1,nvars)
2	        format(f10.4,15f10.3)
	      endif
	      endif
	    endif
	  endif
	enddo

	close(2)

	flag=0

	do i=1,c2
	  if((b2(1,i).eq.seed).and.(flag.eq.0))then
	    write(2,2) (b2(k,i),k=1,nvars)
	    flag=1
	  endif	    
	  if (flag.eq.1)then
c	    if(b2(1,i).ne.seed) then
	    if(b2(1,i).ne.b2(1,i-1)) then
c	      if((b2(1,i).ge.today-10.).and.(b2(1,i).lt.today)) then
	      if(b2(1,i).lt.today+0.5) then
c	print*,b2(0,i),b2(1,i)
	        write(3,2) (b2(k,i),k=1,nvars)
	      endif
	    endif
	  endif
	enddo

	close(3)

        print*, 'Done writting ',input2
        print*, 'Done writting ',input3
	print*,''
	print*,'The next step is to go to the resident directory of'
	print*,'the transmitted data, i.e. /ice/tools/aws/05/temp/'
	print*,'in the case of humboldt data and edit 05.dat and 05t.dat'
	print*,'such that they begin at the same time.  Also clear out'
	print*,'any unreasonable lines at the beginning and end of the'
	print*,'output files such as julian day -123 or julian day 357.'
	print*,'The next step is to go to the resident directory of'
	print*,''
	print*,'Then the data will be ready for gdf.argos to be ran.'
9999	continue

	enddo


      END
