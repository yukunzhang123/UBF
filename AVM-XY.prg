#/ Controller version = 3.14.01
#/ Date = 6/6/2026 5:15 AM
#/ User remarks = 
#0
!PNAME=
!PDESC=
!int i,N,result 
!i=0
!N=4 !define the maximum number of nodes
!!STOP
!!ON ECERR<>0 !this code will be executed only when EtherCAT !Error happens and ECERR variable becomes not 0
!while( i<N )
!      result=ECGETSTATE(i)
!      if result<>8
!            disp i !define a response in this section
!            STOP
!      end
!      i=i+1
!      wait (1000)
!END
!STOP

GLOBAL n
n=GETCONF(310, 0)
disp n
STOP
#1
!PNAME=ACS_State
!PDESC=

WAIT 5000
AUTOEXEC:

!START 7,InitACS
!------- Assignment Variable Parameters -----------------------------------------------
INT MotionStart(INT MontionType);
INT CheckPara(INT MotionType);
INT LastMotionType=0
!--------------------------Init---------------
PA_ComSupMotionType=NoMotion
AP_ComSupMotionRes=MotionReady

!---------------------------------------------
WHILE 1
IF PA_ComSupMotionType=AxisHome			!103
     IF  MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
		   IntervenePositoinMotion=0
		   KILLALL
		   
	     END 
		 
	    START 3,Axis_Home
		PA_AllHomed=0
     END
	 ELSEIF PA_ComSupMotionType=PCOccurAlarm          !105
	 OccurAlarm(AlarmCode_ForcedAlarm,Alarm_High)
	ELSEIF PA_ComSupMotionType=ChuckVacuumOpenMotion				!106
     IF MotionStart(PA_ComSupMotionType)=1
	    START 3,ChuckVacuumOpenMotion
	 END 
	 
ELSEIF PA_ComSupMotionType=ChuckVacuumCloseMotion				!107
     IF MotionStart(PA_ComSupMotionType)=1
	    START 3,ChuckVacuumCloseMotion
	 END
ELSEIF PA_ComSupMotionType=LoadingPinUpMotion			!108
     IF MotionStart(PA_ComSupMotionType)=1
	    START 3,LoadingPinUpMotion
	 END
ELSEIF PA_ComSupMotionType=LoadingPinDownMotion			!109
     IF MotionStart(PA_ComSupMotionType)=1
	    START 3,LoadingPinDownMotion
	 END
	ELSEIF PA_ComSupMotionType=OpticFollowOpenMotion    !113
	 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,CONNECT_Optic_TIR
	 END 
	 ELSEIF PA_ComSupMotionType=OpticFollowCloseMotion    !114
	 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,DISCONNECT_Optic_TIR
	 END 
	 ELSEIF PA_ComSupMotionType=LoadingPinVacuumOpenMotion    !115
	 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,LoadingPinVacuumOpenMotion
	 END
	  ELSEIF PA_ComSupMotionType=LoadingPinVacuumCloseMotion    !116
	 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,LoadingPinVacuumCloseMotion
	 END
	ELSEIF PA_ComSupMotionType=AllEscapeMotion    !120
	 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,ALL_ESCAPE
	 END 	 
	 ELSEIF PA_ComSupMotionType=TIR_Y_IntervenePositoin  ! 130
		 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,TIR_Y_IntervenePositoinMotion
		END
	 
	 	 ELSEIF PA_ComSupMotionType=Open_Optic_CDA  !117
		 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,Open_Optic_CDA
		END
	 
		  ELSEIF PA_ComSupMotionType= Close_Optic_CDA !118
		 IF MotionStart(PA_ComSupMotionType)=1
	 
	 	IF PST(3).#RUN=1
	       STOP 3
	     END 
	 
	    START 3,Close_Optic_CDA
		END 
	 
ELSEIF PA_ComSupMotionType=NoMotion	| PA_ComSupMotionType=PCClearAlarm | PA_ComSupMotionType=PCOccurAlarm  		!0!104!105

ELSEIF PA_ComSupMotionType=StopOptic_X|PA_ComSupMotionType=StopOptic_Y|PA_ComSupMotionType=StopTIR_X|PA_ComSupMotionType=StopTIR_Y|PA_ComSupMotionType=StopOptic_Z|PA_ComSupMotionType=StopLDP_Z !121 122 123 124 125 126

	 WAIT(50)
ELSE	
	 OccurAlarm(AlarmCode_NoMotion,Alarm_Normal)
END
END


INT MotionStart(INT MotionType){ 
   INT RST=-1
   
   IF AP_ACSStatus=ACSStatus_Error
     OccurAlarm(AlarmCode_CanNotMotion,Alarm_Tips)
	 RET RST
   END 
   
   IF AP_ComSupMotionRes=MotionReady | AP_ComSupMotionRes=MotionSuccess
		IF CheckPara(MotionType)=-1
			OccurAlarm(AlarmCode_MotionDataErr,Alarm_Tips)
		ELSE
			AP_ComSupMotionRes=MotionRunning
			RST=1
		END
	ELSEIF AP_ComSupMotionRes=MotionRunning
	   OccurAlarm(AlarmCode_MotionRuning,Alarm_Tips)
    ELSEIF AP_ComSupMotionRes=MotionError
       OccurAlarm(AlarmCode_CanNotMotion,Alarm_Tips)
	END
	LastMotionType=PA_ComSupMotionType
	PA_ComSupMotionType=NoMotion
RET RST
}

INT CheckPara(INT CheckMotionTYpe)
{	
	INT RST = 1
	INT i = 0
	IF CheckMotionTYpe = AxisHome
		IF MAX(PA_HomeOrder) > AxisCount
			RST =- 1
			RET RST
		END
		IF  PA_EC_DI(0).1|PA_EC_DI(0).2<>1
		    RST =- 1
			RET RST
		END
		IF MAX(PA_HomeAxis) < 1
			RST =- 1
			RET RST
		END
		LOOP SIZEOF(PA_HomeAxis) - 1
			IF i > AxisCount
				RST = 1
				RET RST
			END

			IF PA_HomeAxis(i) = 1 & PA_HomeMode(i) <= 0
				RST =- 1
				RET RST
			END

			IF PA_HomeAxis(i) = 1 & PA_HomeVel(i) <= 0
				RST =- 1
				RET RST
			END

			IF PA_HomeAxis(i) = 1 & AST(i).#INHOMING= 1
				RST =- 1
				RET RST
			END

			i = i + 1
		END


	END
	IF PA_ComSupMotionType = LoadingPinUpMotion
		IF PA_AllHomed = 0
			RST =- 1
			OccurAlarm(Alarm_Code_AllAxis_NotHomed,Alarm_High)
			RET RST
		END
		
		IF FPOS(TIR_Y)<LoadingPinFreePosition(TIR_Y)|IntervenePositoinMotion<>1
		  RST=-1
		  OccurAlarm(Alarm_Code_LDP_TIRY_intervene,Alarm_High)
		  RET RST
		  
		END
		
!	IF PA_ComSupMotionType=TIR_Y_IntervenePositoin
!	  IF PA_AllHomed = 0
!	  RST =- 1
!	  OccurAlarm(Alarm_Code_AllAxis_NotHomed,Alarm_High)
!	  END
!	 
!	END
		
		
		
	END
	
	
	

	RET RST
#2
!PNAME=ACS_Fault
!PDESC=
AUTOEXEC:
WAIT 5000
FILL(-1,TIME_OUT,0,9)
INT TIMER(10)
FILL(0,TIMER,0,9)
FILL(10000,Delay,0,1)
FILL (90000,PA_AxiHomeTimeOut)
FILL(10000,Delay,2,6)
FILL(5,Delay,7,9)
INT AllHomeTimeOut=30000
INT TT=0
GLOBAL INT InterveneAlarm
VOID CheckHomeTimeOut();
REAL LodaingPin_Times

VOID CheckAxisError(INT AxisIndex);
LodaingPin_Times=TIME
WHILE 1

!----------AXIS ERROR----------------------------
BLOCK
        CheckAxisError(Optic_X)
		CheckAxisError(Optic_Y)
		CheckAxisError(TIR_X)
		CheckAxisError(TIR_Y)
		CheckAxisError(Optic_Z)
		CheckAxisError(LDP_Z)
!-----------Home Timeout Alarm--------------
IF MAX (HomeAxis)>=0&HomeTimeFlga<>1

CheckHomeTimeOut()

END

IF PA_EC_DO(2).6 <> 1&PA_EC_DO(2).7 <>1&TIME-LodaingPin_Times>10000

OccurAlarm(AlarmCode_LoadingPinUnKonw,Alarm_High)
ELSE
LodaingPin_Times=TIME

END

END

!--------Hertbeat  TimeOut  Alarm----------------------	
	IF CO_Hert=1 
		TestHertTime=TIME
		CO_Hert=2
		AP_AlarmCode(1)=0
	END

	IF CO_Hert=2 &PA_ShieldingHeartBeat=0
		IF TIME-TestHertTime>HertTime
			OccurAlarm(AlarmCode_HeartBeatInterrupt,Alarm_Tips)
!			KILLALL
			DISP"HertTimeOut"
			
		END
	END

END



VOID CheckHomeTimeOut()
{	
	INT i = 0
	INT LimitTime = 90000
	LOOP 6
	IF ABS(FPOS(i)-HomeCurrentPos(i))>HomeLimtiPos(i)
	KILL i
	END
		IF HomeAxis(i) <=0
		ELSE			
			IF ^MFLAGS(HomeAxis(i)).#HOME
				IF PA_AxiHomeTimeOut(HomeAxis(i)) > 0
					LimitTime = PA_AxiHomeTimeOut(HomeAxis(i))
				END
			IF TIME- HomeStartTime(HomeAxis(i)) > LimitTime
				OccurAlarm(161 + HomeAxis(i), Alarm_Normal)
				DISP "HOMETIME OUT",HomeAxis(i)
				HomeAxis(i) =- 1
				KILL i
			END
			
	ELSE		
!		FDEF(HomeAxis(i)).#SRL= 1
!		FDEF(HomeAxis(i)).#SLL= 1
		HomeAxis(i) =- 1
	END
	END
	i++
	END
	RET 
}

VOID CheckAxisError(INT AxisIndex){
 	INT ACode=0
 	INT BitOffset=0 

  	IF FAULT(AxisIndex).#RL=1 & AST(AxisIndex).#INHOMING<>1
    	BitOffset=0
		OccurAlarm(170+AxisIndex,Alarm_Tips)           !!!!!Tips    170-- 175
  	END
  	IF FAULT(AxisIndex).#LL=1 & AST(AxisIndex).#INHOMING<>1
   		BitOffset=1
		OccurAlarm(176+AxisIndex,Alarm_Tips)           !!!!!Tips 176-181
  	END
  	IF FAULT(AxisIndex).#NT=1                           !!!!!  hight   10--15
    	BitOffset=2
		OccurAlarm(10+AxisIndex)
  	END
  	IF FAULT(AxisIndex).#HOT=1                             !!!! 20---25
   		BitOffset=4
		OccurAlarm(20+AxisIndex)
  	END
	IF FAULT(AxisIndex).#SRL=1 & FDEF(AxisIndex).#SRL=1 & AST(AxisIndex).#INHOMING<>1     
    	BitOffset=5 
		OccurAlarm(182+AxisIndex,Alarm_Tips)               !!!!!Tips 182--187
  	END
 	IF FAULT(AxisIndex).#SLL=1 & FDEF(AxisIndex).#SLL=1 & AST(AxisIndex).#INHOMING<>1
    	BitOffset=6
		OccurAlarm(188+AxisIndex,Alarm_Tips)              !!!!!Tips 188--193
  	END
  	IF FAULT(AxisIndex).#ENCNC=1
   		BitOffset=7                                       !!!  30---35
		OccurAlarm(30+AxisIndex)
  	END
! 	IF FAULT(AxisIndex).#ENC2NC=1
!    	BitOffset=8
		!OccurAlarm(BitOffset+ACode)
!  	END
  	IF FAULT(AxisIndex).#DRIVE=1                     !!!!  40---45
    	BitOffset=9
		OccurAlarm(40+AxisIndex)
  	END
 	IF FAULT(AxisIndex).#ENC=1                       !!!! 50--55 
    	BitOffset=10
		OccurAlarm(50+AxisIndex)
  	END
!  	IF FAULT(AxisIndex).#ENC2=1
!   		BitOffset=11
!  		!OccurAlarm(BitOffset+ACode)
!  	END
  	IF FAULT(AxisIndex).#PE=1                   !!!!  137---142
    	BitOffset=12
		OccurAlarm(137+AxisIndex,Alarm_Normal)
  	END
   	IF FAULT(AxisIndex).#CPE=1                 !!!!!143---148
   		BitOffset=13
		OccurAlarm(143+AxisIndex,Alarm_Normal)
  	END
    IF FAULT(AxisIndex).#VL =1             !!!!!!!!60--65
   		BitOffset=14
		OccurAlarm(60+AxisIndex)
  	END
  	IF FAULT(AxisIndex).#AL =1
   		BitOffset=15
		OccurAlarm(70+AxisIndex)
  	END
  	IF FAULT(AxisIndex).#CL=1
    	BitOffset=16
		OccurAlarm(80+AxisIndex)
  	END
   	IF FAULT(AxisIndex).#SP =1
    	BitOffset=17
		OccurAlarm(90+AxisIndex)
  	END
  	IF FAULT(AxisIndex).#STO=1
    	BitOffset=18
		OccurAlarm(100+AxisIndex)
  	END
  	IF FAULT(AxisIndex).#HSSINC=1
    	BitOffset=20
		OccurAlarm(110+AxisIndex)
  	END
  	RET 
}


#3
!PNAME=Move_Type
!PDESC=

VOID SingleAxisHome(INT Axis,INT HomeMode,REAL HomeVel,REAL HomeLimtiPos,REAL HomeOffset,REAL HomeCurrentLimit);
VOID ALLAxis_Home();
REAL startTime
!-----------------------------------Home-------------------------------------------------------------------------------
Axis_Home:
INT IntMin=0
LOOP AxisCount
ALLAxis_Home()
IntMin=IntMin+1
END
LOOP AxisCount
INT axis

TILL MST(axis).#INPOS 

END
TILL MST(0).#INPOS&MST(1).#INPOS&MST(2).#INPOS&MST(3).#INPOS
MFLAGS(1).#NANO=1
MotionEnd(MotionSuccess)
STOP

!pan duan huei yuan shun xu
VOID ALLAxis_Home()
{	
	INT i = 0
	INT j = 0
	INT k = 0
	INT l = 0
	FILL(- 1, HomeAxis)
	LOOP SIZEOF(PA_HomeAxis) - 1
		IF PA_HomeAxis(i) = 1
			k = k + 1
			IF PA_HomeOrder(i) = IntMin
				HomeStartTime(i) = TIME
				HomeAxis(j) = i
				OffsetAxis = j
				SingleAxisHome(HomeAxis(j), PA_HomeMode(i), PA_HomeVel(i),HomeLimtiPos(i), PA_HomeOffset(i), PA_HomeCurrentLimit(i)) !hui yuan cehng xu
				l = 1
				j = j + 1
			END
	END
	i = i + 1
	END

	IF 1 !k>1
		i = 0
		j = 0
		LOOP SIZEOF(PA_HomeAxis)
			IF PA_HomeOrder(i) = IntMin & PA_HomeAxis(i) = 1
				startTime = TIME
				WHILE ^MFLAGS(i).#HOME !Pan Duan Hui Ling Wan Cheng
				    IndexHomePosition(i)=IND(i)
					IF TIME- startTime > PA_AxiHomeTimeOut(i) & PA_AxiHomeTimeOut(i) > 0
						OccurAlarm(AlarmCode_HomeTimeOut, Alarm_Normal, 3)
						DISP "AlarmCode_HomeTimeOut", AlarmCode_HomeTimeOut
					END
			END
		IF 1
			PTP/V i, 0,50
			DISP "MOVE ZERO",i
		END

	FDEF(i).#SRL = 1
	FDEF(i).#SLL = 1
	FDEF(i).#RL=1
	FDEF(i).#LL=1
!	FMASK(i).#SRL=1
!	FMASK(i).#SlL=1
!   SRLIMIT(i)=PA_LimitP(i)
!	SLLIMIT(i)=PA_LimitN(i)
	PA_HomeAxis(i) = 0
	HomeAxis(i) =- 1
	j = j + 1
	END
	i = i + 1
	END
	ELSEIF l = 1
		FILL(0, PA_HomeAxis)
	FDEF(i).#SRL = 1
	FDEF(i).#SLL = 1

	END
	RET
}

VOID SingleAxisHome(INT Axis,INT HomeMode,REAL HomeVel,REAL HomeLimtiPos,REAL HomeOffset,REAL HomeCurrentLimit){
	FCLEAR ALL
	DISP "Axis",Axis
	ENABLE Axis
	IF Axis=1
	MFLAGS(1).#NANO=0
	END
IF HomeMode = 18&FAULT(Axis).#RL
	JOG/V Axis, -1
		TILL ^FAULT(Axis).#RL
		KILL Axis
		WAIT 100
	TILL ^AST(Axis).#MOVE
END
IF HomeMode = 17&FAULT(Axis).#LL

		JOG/V Axis, 1
		TILL ^FAULT(Axis).#LL
		KILL Axis
		WAIT 100
		END

IF MFLAGS(TIR_X).#DEFCON=0  |MFLAGS(TIR_Y).#DEFCON=0 
MFLAGS(TIR_X).#DEFCON=1  
MFLAGS(TIR_Y).#DEFCON=1 
END

	MFLAGS(Axis).#HOME=0
	FDEF(Axis).#SRL=0
	FDEF(Axis).#SLL=0
	FDEF(Axis).#RL=0
	FDEF(Axis).#LL=0
   	startTime=TIME
   
	HOMEVELL(Axis) =HomeVel
	HOMEVELI(Axis) =HomeVel/2
	ACC(Axis)=10*HomeVel
	DEC(Axis)=10*HomeVel
	JERK(Axis)=100*HomeVel
	HomeOffset=-1*HomeOffset
	DISP"Axis,HomeMode,HomeVel,HomeOffset:",Axis,HomeMode,HomeVel,HomeOffset
	HomeTimeFlga=0
	HomeCurrentPos(Axis)=FPOS(Axis)
	HOME Axis,HomeMode,HomeVel,HomeLimtiPos ,HomeOffset,HomeCurrentLimit

RET
}

ChuckVacuumOpenMotion:
   IF  PA_EC_DO(3).2<>1
       PA_EC_DO(3).2=1   
   END
   MotionEnd(MotionSuccess)
   DISP "ChuckVacuumOpenMotion OK"
STOP

ChuckVacuumCloseMotion:
   IF  PA_EC_DO(3).2<>0
       PA_EC_DO(3).2=0   
   END
   MotionEnd(MotionSuccess)
   DISP "ChuckVacuumCloseMotion OK"
STOP

LoadingPinUpMotion:
!!!!up

PA_EC_DO(2).6 = 1;
PA_EC_DO(2).7 = 0
T(1)=TIME
TILL PA_EC_DI(0).1 = 1
!PA_EC_DO(2).6 = 0;

IF TIME -T(1)>5500
!OccurAlarm(LoadingPinUpTimeOut)
DISP "LoadingPinUpTimeOut"
END
MotionEnd(MotionSuccess)
STOP
DISP "LoadingPinUpMotion OK"
LoadingPinDownMotion:

PA_EC_DO(2).7 = 1;
PA_EC_DO(2).6 = 0
T(2)=TIME
TILL PA_EC_DI(0).2 = 1
!PA_EC_DO(2).7 = 0;
IF TIME -T(2)>5500
!OccurAlarm(LoadingPinDownTimeOut)
DISP "LoadingPinDownTimeOut"
END
MotionEnd(MotionSuccess)
DISP "LoadingPinDownMotion OK"
STOP



LoadingPinVacuumOpenMotion:
IF PA_EC_DO(3).6 <> 1
	PA_EC_DO(3).6 = 1
END
MotionEnd(MotionSuccess)
DISP "LoadingPinVacuumOpenMotion OK"
STOP

LoadingPinVacuumCloseMotion:
IF PA_EC_DO(3).6 <> 0
	PA_EC_DO(3).6 = 0
END
MotionEnd(MotionSuccess)
DISP "LoadingPinVacuumCloseMotion OK"
STOP




ALL_ESCAPE:
ENABLE ALL
TILL MST(Optic_X).#ENABLED &MST(Optic_Y).#ENABLED&MST(TIR_X).#ENABLED&MST(TIR_Y).#ENABLED&MST(Optic_Z).#ENABLED&MST(LDP_Z).#ENABLED
BLOCK
PTP/V Optic_X,M_Pos(0)(0),M_Vel(0)(0)
PTP/V Optic_Y,M_Pos(1)(0),M_Vel(0)(0)
PTP/V TIR_X,M_Pos(2)(0),M_Vel(0)(0)
PTP/V TIR_Y,M_Pos(3)(0),M_Vel(0)(0)
PTP/V Optic_Z,M_Pos(4)(0),M_Vel(0)(0)
PTP/V LDP_Z,M_Pos(5 )(0),M_Vel(0)(0)
END
MotionEnd(MotionSuccess)
STOP



TIR_Y_IntervenePositoinMotion:
IF PA_AllHomed = 0
	OccurAlarm(Alarm_Code_AllAxis_NotHomed, Alarm_High)
ELSE
ENABLE TIR_Y
FMASK(TIR_Y).#RL=1

JOG/V TIR_Y,10
TILL FAULT(TIR_Y).#RL
HALT TIR_Y
LimitRightPosition(TIR_Y)=FPOS(TIR_Y)
LoadingPinFreePosition(TIR_Y)=-(FreeDstence-LimitRightPosition(TIR_Y))
PTP/V TIR_Y,0,10
END
TILL ^MST(TIR_Y).#MOVE|-0.01<FPOS(TIR_Y)<0.01
IntervenePositoinMotion=1
AP_AlarmCode(173)=0

MotionEnd(MotionSuccess)
DISP "TIR_Y_IntervenePositoinMotion OK"
STOP

Open_Optic_CDA:

PA_EC_DO(0).0=1
TILL PA_EC_DO(0).0=1
MotionEnd(MotionSuccess)
DISP "Open_Optic_CDA OK"
STOP


Close_Optic_CDA:

PA_EC_DO(0).0=0
TILL PA_EC_DO(0).0=0
MotionEnd(MotionSuccess)
DISP "Close_Optic_CDA OK"
STOP


CONNECT_Optic_TIR:
!DISP "CONNECT_Optic_TIR:"
MFLAGS(TIR_X).#DEFCON=0  !CONNECT is allowed. axis1 is Slave;
MFLAGS(TIR_Y).#DEFCON=0  !CONNECT is allowed. axis1 is Slave;
CONNECT RPOS(TIR_X) = APOS(Optic_X)
CONNECT RPOS(TIR_Y) = APOS(Optic_Y)
WAIT 50
DEPENDS TIR_X,Optic_X
DEPENDS TIR_Y,Optic_Y
PA_EC_DO(3).7=1
DISP"CONNECT_Optic_TIR_OK"
MotionEnd(MotionSuccess)
STOP

DISCONNECT_Optic_TIR:
!DISP "DISCONNECT_Optic_TIR:"
MFLAGS(TIR_X).#DEFCON=1;	MFLAGS(TIR_Y).#DEFCON=1
DISP"DISCONNECT_Optic_TIR_OK"
PA_EC_DO(3).7=0
MotionEnd(MotionSuccess)
STOP
#4
!PNAME=
!PDESC=
PA_ComSupMotionType=PCClearAlarm
FILL (0,PA_HomeOrder)
FILL (1,PA_HomeOrder,5,5)

!FILL (2,PA_HomeOrder,4,4)
!FILL (3,PA_HomeOrder,0,3)
!FILL (0,PA_HomeOrder,1,1)
FILL (0,PA_HomeAxis)
FILL (1,PA_HomeAxis,5,5)
!PA_HomeAxis(4)=0
PA_ComSupMotionType=AxisHome


STOP
#5
!PNAME=IO_Mapping
!PDESC=
!----------------IO=---------------
AUTOEXEC:
WAIT 5000

WHILE 1


!!---DI Mapping-------------------------------------------------------
ECIN(72,PA_EC_DI(0))  !1:PN LoadingPins up 2:PN LoadingPins down

!!---DO Mapping---
ECOUT(76,PA_EC_DO(0)) !0:Camera CDA Open
!!---AI Mapping---
ECIN(76,PA_EC_AI(1))  ! Wafer Chuck Vac
ECIN(78,PA_EC_AI(6))  ! ATF INPOS
ECIN(80,PA_EC_AI(3))  ! Loading Pins VAC
ECIN(82,PA_EC_AI(4))  ! MAC Bellows CDA
ECIN(84,PA_EC_AI(5))  ! Loading Pins CDA 11111
ECIN(86,PA_EC_AI(7))  ! Camera CDA

!!---AO Mapping---	!0 ~ 655357 --- 0 ~ +10V	   D=(65535/10)*U
ECOUT(78,PA_EC_AO(4))  ! Reflectiv IR
ECOUT(82,PA_EC_AO(0))	! T-IR
ECOUT(84,PA_EC_AO(8))	!Autofocus

!!---Festo Mapping---
ECOUT(372,PA_EC_DO(2))
ECOUT(373,PA_EC_DO(3))


WAIT 50

END

STOP
#6
!PNAME=Axis_PID
!PDESC=
SLVKP(1)=90
SLVKI(1)=250
SLPKP(1)=250
SLAFF(1)=8000
MFLAGS(1).#NOTCH=1
MFLAGS(1).#NOFILT=1
MFLAGS(1).#NANO=1
SLVSOF (1)=300
SLVNFRQ(1)=163
SLVNWID(1)=5
SLVNATT(1)=5
SLFRC(1)=30
SLFRCN(1)=34
TARGRAD(1)=0.005
 SLZFF(1)=0.001
SLDZMAX(1)=0.005 
SLDZMIN(1)=0.001
SLDZTIME(1) =1


SLVKP(0)=80
SLVKI(0)=200
SLPKP(0)=200
SLAFF(0)=2000
SLFRC(0)=29
SLFRCN(0)=20
MFLAGS(0).#NOFILT=0
SLVSOF (0)=400
MFLAGS(0).#NANO=1
TARGRAD(0)=0.005
 SLZFF(0)=0.005
SLDZMAX(0)=0.005
SLDZMIN(0)=0.001
SLDZTIME(0) =1



SLVKP(2)=70
SLVKI(2)=400
SLPKP(2)=200
SLAFF(2)=3000
SLFRC(2)=30
SLFRCN(2)=16
MFLAGS(2).#NOFILT=0
MFLAGS(2).#NANO=1
TARGRAD(2)=0.005
 SLZFF(2)=0.005
SLDZMAX(2)=0.005
SLDZMIN(2)=0.001
SLDZTIME(2) =1


SLVKP(3)=70
SLVKI(3)=250
SLPKP(3)=200
SLVKPIF(3)=0
SLVKPSF(3)=3
SLVRAT(3)=1
SLJFF(3)=0
SLAFF(3)=5000
SLFRC(3)=10
SLFRCN(3)=20
MFLAGS(3).#NOFILT=0
MFLAGS(3).#NANO=1
SLVSOF (3)=700

TARGRAD(3)=0.005
 SLZFF(3)=0.001
SLDZMAX(3)=0.005 
SLDZMIN(3)=0.001
SLDZTIME(3) =1
STOP

#7
!PNAME=Initialize
!PDESC=
AUTOEXEC:
WAIT 5000
InitACS:

PA_ShieldingHeartBeat=0
IntervenePositoinMotion=0
HertTime=60000


!-----------------------------------2.StartBuffer------------------

IF PST(1).#RUN<>1
START 1,1
END
IF PST(2).#RUN<>1
START 2,1
END
IF PST(5).#RUN<>1
START 5,1
END


!-------------------------------------3.Variable Init --------------------
FDEF(Optic_X).#SRL=1       !!!!Soft Limit Open
FDEF(Optic_X).#SLL=1
FDEF(Optic_Y).#SRL=1
FDEF(Optic_Y).#SLL=1
FDEF(TIR_X).#SRL=1
FDEF(TIR_X).#SLL=1
FDEF(TIR_Y).#SRL=1
FDEF(TIR_Y).#SLL=1
FDEF(Optic_Z).#SRL=1
FDEF(Optic_Z).#SLL=1
FDEF(LDP_Z).#SRL=1
FDEF(LDP_Z).#SLL=1

PA_LimitP(Optic_X)=35
PA_LimitN(Optic_X)=-260

PA_LimitP(Optic_Y)=4
PA_LimitN(Optic_Y)=-283

PA_LimitP(TIR_X)=35
PA_LimitN(TIR_X)=-260

PA_LimitP(TIR_Y)=13
PA_LimitN(TIR_Y)=-300

PA_LimitP(Optic_Z)=0.1
PA_LimitN(Optic_Z)=-36

PA_LimitP(LDP_Z)=35.5
PA_LimitN(LDP_Z)=-1

SRLIMIT(Optic_X)=PA_LimitP(Optic_X)
SLLIMIT(Optic_X)=PA_LimitN(Optic_X)

SRLIMIT(Optic_Y)=PA_LimitP(Optic_Y)
SLLIMIT(Optic_Y)=PA_LimitN(Optic_Y)

SRLIMIT(TIR_X)=PA_LimitP(TIR_X)
SLLIMIT(TIR_X)=PA_LimitN(TIR_X)

SRLIMIT(TIR_Y)=PA_LimitP(TIR_Y)
SLLIMIT(TIR_Y)=PA_LimitN(TIR_Y)

SRLIMIT(Optic_Z)=PA_LimitP(Optic_Z)
SLLIMIT(Optic_Z)=PA_LimitN(Optic_Z)

SRLIMIT(LDP_Z)=PA_LimitP(LDP_Z)
SLLIMIT(LDP_Z)=PA_LimitN(LDP_Z)


PA_EC_DO(0).0=1


HomeLimtiPos(Optic_X)=300
HomeLimtiPos(Optic_Y)=300
HomeLimtiPos(TIR_X)=300
HomeLimtiPos(TIR_Y)=300
HomeLimtiPos(Optic_Z)=37
HomeLimtiPos(LDP_Z)=38

PA_HomeVel(Optic_X)=10;  PA_HomeMode(Optic_X)=2  ;  PA_HomeOffset(Optic_X)=0 ;     PA_HomeCurrentLimit(Optic_X)=50
PA_HomeVel(Optic_Y)=10 ; PA_HomeMode(Optic_Y)=2   ; PA_HomeOffset(Optic_Y)=0  ;    PA_HomeCurrentLimit(Optic_Y)=70  
PA_HomeVel(Optic_Z)=2 ;  PA_HomeMode(Optic_Z)=18  ; PA_HomeOffset(Optic_Z)=0    ;    PA_HomeCurrentLimit(Optic_Z)=50
PA_HomeVel(LDP_Z)=2   ;  PA_HomeMode(LDP_Z)=17    ; PA_HomeOffset(LDP_Z)=0      ;    PA_HomeCurrentLimit(LDP_Z)=50
PA_HomeVel(TIR_X)=10  ;  PA_HomeMode(TIR_X)=2    ;  PA_HomeOffset(TIR_X)=30.7418   ;PA_HomeCurrentLimit(TIR_X)=50
PA_HomeVel(TIR_Y)=10  ;  PA_HomeMode(TIR_Y)=2    ;  PA_HomeOffset(TIR_Y)=0.916  ; PA_HomeCurrentLimit(TIR_Y)=80
STOP																				
#8
!PNAME=Clear_Error
!PDESC=
ON PA_ComSupMotionType=PCClearAlarm & PST(8).#RUN<>1
FCLEAR ALL
 INT i=0
 AP_ACSStatus=ACSStatus_OK
 FILL (0,AP_AlarmCode)
! STOP 4
STOP 3
 	IF PST(1).#RUN<>1
	   START 1,1
	END
	IF PST(2).#RUN<>1
	  START 2,1
	END
	IF PST(5).#RUN<>1
	  START 5,1
	END
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionReady
 	
 
!  BLOCK
!     IF MAX(PA_ClearAlarmCode)>0 & MAX(AP_AlarmCode)>0
!        LOOP SIZEOF(AP_AlarmCode)-1
!           IF AP_AlarmCode(i)=1 & PA_ClearAlarmCode(i)=1
!              AP_AlarmCode(i)=0
!              PA_ClearAlarmCode(i)=0
!            END
!           i=i+1
!        END
!     END
!  END
!    FCLEAR ALL
! IF MAX(AP_AlarmCode,0,500)<1
!	AP_ACSStatus=ACSStatus_OK
!    AP_ComSupMotionRes=MotionReady
!	IF PST(1).#RUN<>1
!	   START 1,1
!	END
!	IF PST(2).#RUN<>1
!	  START 2,1
!	END
! END
! 	FILL(0,BufferErrRow,0,15)
 DISP "CLEAR ALARM OK"	

RET 

ON PA_ComSupMotionType=StopOptic_X       !121  
IF PST(3).#RUN=1

STOP 3
KILLALL
HomeTimeFlga=1
END

KILL Optic_X
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionSuccess
RET

ON PA_ComSupMotionType=StopOptic_Y       !122  
IF PST(3).#RUN=1

STOP 3
KILLALL
HomeTimeFlga=1
END

KILL Optic_Y
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionSuccess
RET

ON PA_ComSupMotionType=StopTIR_X       !123  
IF PST(3).#RUN=1

STOP 3
KILLALL
HomeTimeFlga=1
END

KILL TIR_X
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionSuccess
RET

ON PA_ComSupMotionType=StopTIR_Y       !124  
IF PST(3).#RUN=1

STOP 3
KILLALL
HomeTimeFlga=1
END

KILL TIR_Y
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionSuccess
RET

ON PA_ComSupMotionType=StopOptic_Z       !125  
IF PST(3).#RUN=1

STOP 3
KILLALL
HomeTimeFlga=1
END

KILL Optic_Z
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionSuccess
RET

ON PA_ComSupMotionType=StopLDP_Z       !126  
IF PST(3).#RUN=1

STOP 3
HomeTimeFlga=1
KILLALL
END
PA_ComSupMotionType=NoMotion
  AP_ComSupMotionRes=MotionSuccess
KILL LDP_Z

RET

!ON PA_EC_DI(0).1
!KILL (TIR_X,TIR_Y)
!!DISABLE (TIR_X,TIR_Y)
!RET


ON ^PST(5).#RUN
START 5,1
RET


ON PST(1).#RUN<>1 | PST(2).#RUN<>1
	WAIT(1000) 
	
		OccurAlarm(AlarmCode_StateMachineNotRun,Alarm_High) 
		DISP"buffer 1 or 2 stop"
	
RET



#9
!PNAME=ON
!PDESC=
GLOBAL REAL AxisErrorPos(500)
GLOBAL REAL AxisErrorPos1(500)
GLOBAL REAL AxisErrorPos2(500)
int i=0
INT J=0
INT K=0
ON VEL(Optic_X) > 150
VEL(Optic_X) = 50
RET

ON VEL(Optic_Y) > 150
VEL(Optic_Y) = 50
RET

ON VEL(TIR_X) > 150
VEL(TIR_X) = 50
RET

ON VEL(TIR_Y) > 150
VEL(TIR_Y) = 50
RET

ON VEL(Optic_Z) > 15
VEL(Optic_Z) = 10
RET

ON VEL(LDP_Z) > 12
VEL(LDP_Z) = 10
RET


ON PA_EC_DO(3).7=1&^MST(TIR_X).#ENABLED&MST(Optic_X).#ENABLED
ENABLE (TIR_X)
RET

ON PA_EC_DO(3).7 = 1&MST(TIR_X).#ENABLED & ^MST(Optic_X).#ENABLED
DISABLE TIR_X
RET

ON PA_EC_DO(3).7 = 1&^MST(TIR_Y).#ENABLED & MST(Optic_Y).#ENABLED
ENABLE TIR_Y
RET

ON PA_EC_DO(3).7 = 1&MST(TIR_Y).#ENABLED & ^MST(Optic_Y).#ENABLED
DISABLE TIR_Y
RET

ON (MFLAGS(Optic_X).#HOME&MFLAGS(Optic_Y).#HOME&MFLAGS(TIR_X).#HOME&MFLAGS(TIR_Y).#HOME&MFLAGS(Optic_Z).#HOME&MFLAGS(LDP_Z).#HOME)&PA_AllHomed<>1

PA_AllHomed=1
PA_EC_DO(0).31=1
RET

ON (^MFLAGS(Optic_X).#HOME|^MFLAGS(Optic_Y).#HOME|^MFLAGS(TIR_X).#HOME|^MFLAGS(TIR_Y).#HOME|^MFLAGS(Optic_Z).#HOME|^MFLAGS(LDP_Z).#HOME)&PA_AllHomed<>0
PA_AllHomed=0
PA_EC_DO(0).31=0
!DISP "333"
RET

ON FPOS(LDP_Z) > 15 & (FVEL(TIR_X)>5| FVEL(TIR_Y)>5)
!KILLALL
AxisErrorPos1(J)=FPOS(LDP_Z)
J++
OccurAlarm(Alarm_Code_LDP_Z_TIR_intervene, Alarm_Tips)

RET

ON (PA_EC_DI(0).1 = 1)&(FVEL(TIR_X)>4| FVEL(TIR_Y)>4|FVEL(Optic_X)>4| FVEL(Optic_Y)>4)
!KILLALL
!DISP "111"
AxisErrorPos2(K)=FPOS(TIR_X)
K++
OccurAlarm(Alarm_Code_LDP_TIRY_intervene,Alarm_High)
RET

ON FAULT(Optic_X).#PE=1
OccurAlarm(137,Alarm_Normal)
RET
ON FAULT(Optic_Y).#PE=1
AxisErrorPos(i)=FPOS(Optic_Y)
i++
OccurAlarm(138,Alarm_Normal)
RET
ON FAULT(TIR_X).#PE=1
OccurAlarm(139,Alarm_Normal)
RET
ON FAULT(TIR_Y).#PE=1
OccurAlarm(140,Alarm_Normal)
RET
ON FAULT(Optic_Z).#PE=1
OccurAlarm(141,Alarm_Normal)
RET
ON FAULT(LDP_Z).#PE=1
OccurAlarm(142,Alarm_Normal)
RET




ON FAULT(Optic_X).#CPE=1
OccurAlarm(143,Alarm_Normal)
RET
ON FAULT(Optic_Y).#CPE=1
OccurAlarm(144,Alarm_Normal)
RET
ON FAULT(TIR_X).#CPE=1
OccurAlarm(145,Alarm_Normal)
RET
ON FAULT(TIR_Y).#CPE=1
OccurAlarm(146,Alarm_Normal)
RET
ON FAULT(Optic_Z).#CPE=1
OccurAlarm(147,Alarm_Normal)
RET
ON FAULT(LDP_Z).#CPE=1
OccurAlarm(148,Alarm_Normal)
RET

ON FAULT(Optic_X).#VL=1
OccurAlarm(60,Alarm_High)
RET
ON FAULT(Optic_Y).#VL=1
OccurAlarm(61,Alarm_High)
RET
ON FAULT(TIR_X).#VL=1
OccurAlarm(62,Alarm_High)
RET
ON FAULT(TIR_Y).#VL=1
OccurAlarm(63,Alarm_High)
RET
ON FAULT(Optic_Z).#VL=1
OccurAlarm(64,Alarm_High)
RET
ON FAULT(LDP_Z).#VL=1
OccurAlarm(65,Alarm_High)
RET




#A
!PNAME=
!PDESC=
!axisdef X=0,Y=1,Z=2,T=3,A=4,B=5,C=6,D=7
!axisdef x=0,y=1,z=2,t=3,a=4,b=5,c=6,d=7

AXISDEF Optic_X=0,Optic_Y=1,TIR_X=2,TIR_Y=3,Optic_Z=4,LDP_Z=5

global int I(100),I0,I1,I2,I3,I4,I5,I6,I7,I8,I9,I90,I91,I92,I93,I94,I95,I96,I97,I98,I99
global real V(100),V0,V1,V2,V3,V4,V5,V6,V7,V8,V9,V90,V91,V92,V93,V94,V95,V96,V97,V98,V99


!-------------------------Axis Init---------------
GLOBAL INT AxisCount=6
GLOBAL INT AxisNums(6)
AxisNums(0)=0;AxisNums(1)=1;AxisNums(2)=2;AxisNums(3)=3;AxisNums(4)=4;AxisNums(5)=5
GLOBAL T(10)
GLOBAL INT HomeTimeFlga
GLOBAL REAL HomeCurrentPos(32)
GLOBAL REAL HomeLimtiPos(32)

GLOBAL INT PA_HomeOrder(32)
GLOBAL INT HomeAxis(32)
GLOBAL INT PA_HomeMode(32)
GLOBAL REAL PA_HomeVel(32)
GLOBAL REAL PA_HomeOffset(32)
GLOBAL INT PA_AxiHomeTimeOut(32)
GLOBAL REAL HomeStartTime(32)
GLOBAL INT PA_HomeAxis(32)
GLOBAL INT PA_HomeCurrentLimit(32)
GLOBAL INT PA_AllHomed

GLOBAL REAL PA_LimitP(6)
GLOBAL REAL PA_LimitN(6)

!-------------------------Loading_interference---------------

GLOBAL REAL IndexHomePosition(32)
GLOBAL REAL LimitRightPosition(32)
GLOBAL REAL LimitLeftPosition(32)
GLOBAL REAL LoadingPinFreePosition(32)

GLOBAL REAL CONST FreeDstence=50
GLOBAL INT IntervenePositoinMotion=0
!------Mapping----------
GLOBAL INT PA_EC_DI(3),PA_EC_DO(6),PA_EC_AI(16),PA_EC_AO(16)
GLOBAL INT LoadingUp_DI,LoadingDown_DI,AutofocusInpos	!DI Mapping
GLOBAL INT WaferChuckVAC_AI,LoadingVAC_AI,BellowsCDA,LoadingPinsCDA	!AI Mapping
GLOBAL REAL Purage_inner_circle,Autofocus	!AO Mapping
GLOBAL INT LoadingUp_DO,LoadingDown_DO,LoadingVac_DO,WaferChuckVac_DO	!Festo Mapping

!------Array------------
GLOBAL INT Status(32),Alarm(10)
GLOBAL REAL M_Pos(16)(16),M_Vel(16)(16)
GLOBAL INT TIME_OUT(10),StepTime(100)
GLOBAL INT Delay(10)
GLOBAL INT HOMETIME(10)

!-----Step Control-------
GLOBAL INT Disconnected=1,Connected=2,Initializing=3,EnableOK=4,MaintenanceMode=5,DisableOK=7,Failed=8
GLOBAL INT GetWaferRuning=1,GetWaferFinished=2,GetWaferFault=-1,GetWaferInital=0
GLOBAL INT RecipRunRuning=1,RecipRunFinished=2,RecipRunFault=-1,RecipRunInital=0
GLOBAL INT OutWaferRunRuning=1,OutWaferRunFinished=2,OutWaferRunFault=-1,OutWaferInital=0
GLOBAL INT GetWafer_Step=0,RecipRun_Step=0,OutWafer_Step=0

!------ACS TO PC-----
GLOBAL INT HertTime=3000
GLOBAL INT CO_Hert=2
GLOBAL INT PA_ShieldingHeartBeat
GLOBAL INT AP_OutputOK
GLOBAL INT OffsetAxis


!------------------Alarm_Hight------------
GLOBAL CONST INT AlarmCode_HeartBeatInterrupt=1
GLOBAL CONST INT AlarmCode_StateMachineNotRun=2
GLOBAL CONST INT Alarm_Code_LDP_TIRY_intervene=4
GLOBAL CONST INT Alarm_Code_AllAxis_NotHomed=5
GLOBAL CONST INT Alarm_Code_LDP_Z_TIR_intervene=6
!GLOBAL CONST INT LoadingPinUpTimeOut=5
!GLOBAL CONST INT LoadingPinDownTimeOut=6
GLOBAL CONST INT AlarmCode_LoadingPinUnKonw=7
GLOBAL CONST INT AlarmCode_ForcedAlarm=8





!--------home time out alarm-------
GLOBAL CONST INT Optic_X_HomeTimeOut=131
GLOBAL CONST INT Optic_Y_HomeTimeOut=132
GLOBAL CONST INT TIR_X_HomeTimeOut=133
GLOBAL CONST INT TIR_Y_HomeTimeOut=134
GLOBAL CONST INT Optic_Z_HomeTimeOut=135
GLOBAL CONST INT LDP_Z_HomeTimeOut=136



GLOBAL CONST INT AlarmCode_MotionDataErr=121
GLOBAL CONST INT AlarmCode_HomeTimeOut=123
GLOBAL CONST INT AlarmCode_NoMotion=162
GLOBAL CONST INT AlarmCode_NeedleExistInterveneRisk=163
GLOBAL CONST INT AlarmCode_CameraExistInterveneRisk=164
GLOBAL CONST INT AlarmCode_CanNotMotion=165
GLOBAL CONST INT AlarmCode_MotionRuning=166


!-----Alarm Limit------
GLOBAL INT LoadingVAC_AI_RLimit=199
GLOBAL INT ChuckVAC_AI_RLimit=195;


!----TEST----------
GLOBAL INT TimeOutTest,TestCount
GLOBAL REAL TestHertTime


!---------------MotionType-----------------
GLOBAL CONST INT NoMotion=0
GLOBAL CONST INT CheckAxisHomeTimeOut=101
GLOBAL CONST INT LaserCompensate=102
GLOBAL CONST INT AxisHome=103
GLOBAL CONST INT PCClearAlarm=104
GLOBAL CONST INT PCOccurAlarm=105
GLOBAL CONST INT ChuckVacuumOpenMotion=106
!GLOBAL CONST INT SynPid=106
GLOBAL CONST INT ChuckVacuumCloseMotion=107
GLOBAL CONST INT LoadingPinUpMotion=108
GLOBAL CONST INT LoadingPinDownMotion=109
GLOBAL CONST INT LoadingPinVacuumOpenMotion=115
GLOBAL CONST INT LoadingPinVacuumCloseMotion=116
GLOBAL CONST INT AutoFocusMotion=110
GLOBAL CONST INT ReflectMotion=111
GLOBAL CONST INT TransmissiveIRMotion=112
GLOBAL CONST INT OpticFollowOpenMotion=113
GLOBAL CONST INT OpticFollowCloseMotion=114
GLOBAL CONST INT AllEscapeMotion=120
GLOBAL CONST INT StopOptic_X=121
GLOBAL CONST INT StopOptic_Y=122
GLOBAL CONST INT StopTIR_X=123
GLOBAL CONST INT StopTIR_Y=124
GLOBAL CONST INT StopOptic_Z=125
GLOBAL CONST INT StopLDP_Z=126

GLOBAL CONST INT TIR_Y_IntervenePositoin=130
GLOBAL CONST INT Open_Optic_CDA=117
GLOBAL CONST INT Close_Optic_CDA=118
!------------ClearAlarm-----------------
GLOBAL INT PA_ClearAlarmCode(200)
GLOBAL INT AP_AlarmCode(200)

!---------------ALARM-----------------------
GLOBAL INT AP_ACSStatus=1
GLOBAL CONST INT ACSStatus_Error=-1
GLOBAL CONST INT ACSStatus_Tips=-2
GLOBAL CONST INT ACSStatus_OK=1
!---------------ALARMGrade-----------------------
GLOBAL CONST INT Alarm_High=1
GLOBAL CONST INT Alarm_Normal=2
GLOBAL CONST INT Alarm_Tips=3
GLOBAL CONST INT Alarm_Buffer=4
!---------------MotionStatus-------------
GLOBAL CONST INT MotionReady=0
GLOBAL CONST INT MotionRunning=2
GlOBAL CONST INT MotionSuccess=1
GLOBAL CONST INT MotionError=-1

GLOBAL INT AP_ComSupMotionRes
GLOBAL INT PA_ComSupMotionType






INT GetAlarmLevel(INT AlarmCode){
INT Level=0
IF AlarmCode<=120
Level=1
ELSEIF 121<AlarmCode<=160
Level=2
ELSEIF 161<AlarmCode<=200
Level=3
!ELSEIF 300<AlarmCode<=400
!Level=4
END

RET Level
}

VOID OccurAlarm(INT AlarmCode,INT AlarmLevel=0,INT Buffer1=-1,INT Buffer2=-1){
 DISP "Alarm",AlarmCode
 IF AlarmCode>SIZEOF(AP_AlarmCode)
  RET
 END
 
  IF Buffer1<>-1
   STOP Buffer1
 END 
  IF Buffer2<>-1
   STOP Buffer2
 END 
 
 IF AlarmLevel=0
   AlarmLevel=GetAlarmLevel(AlarmCode)
 END
 
 IF AP_AlarmCode(AlarmCode)=1
   RET 
 END 
 
    AP_AlarmCode(AlarmCode)=1
 IF AlarmLevel=Alarm_High
   PA_ComSupMotionType=NoMotion
!   AP_ComSupMotionRes=MotionError
   AP_ACSStatus=ACSStatus_Error
  KILLALL
  WAIT 1000
  DISABLE 0
  DISABLE 1
  DISABLE 2
  DISABLE 3
!  DISABLE 4
ELSEIF AlarmLevel=Alarm_Normal
   PA_ComSupMotionType=NoMotion
   AP_ACSStatus=ACSStatus_Error
!   AP_ComSupMotionRes=MotionError
ELSEIF AlarmLevel=Alarm_Tips
   IF AP_ACSStatus<>ACSStatus_Error
      AP_ACSStatus=ACSStatus_Tips
    END
ELSEIF AlarmLevel=Alarm_Buffer
   PA_ComSupMotionType=NoMotion
   AP_ACSStatus=ACSStatus_Error
ELSE
END
RET
}

VOID ClearAlarm(){
 INT i=0
 LOOP SIZEOF(AP_AlarmCode)-1
  IF MAX(PA_ClearAlarmCode)<1
     RET 
  END
  IF AP_AlarmCode(i)=1 & PA_ClearAlarmCode(i)=1
       AP_AlarmCode(i)=0
       PA_ClearAlarmCode(i)=0
   END
  END
 IF MAX(AP_AlarmCode,0,200)<1
    AP_ACSStatus=ACSStatus_OK
    AP_ComSupMotionRes=MotionReady
    FCLEAR ALL
	IF PST(1).#RUN<>1
	   START 1,1
	END
	IF PST(2).#RUN<>1
	  START 2,1
	END
  IF PST(8).#RUN<>1
	  START 2,1  
	END
 END
 	STOP 3 
RET
}
VOID MotionEnd(INT EndType){
PA_ComSupMotionType=NoMotion
AP_ComSupMotionRes=EndType
RET
}
