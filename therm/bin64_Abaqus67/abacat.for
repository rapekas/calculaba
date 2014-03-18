!
!
! Abacat.for regroupe l'ensemble des user subroutines utilisees 
!              pour coupler CAT à ABAQUS.
!
!
! ***********************************************************************************************************************
!
! Les routines modifiees sont :
!
! - FILM :        Le calcul des convections se fait en passant à ABAQUS les (h,T) 
!                  de chaque face externe.
!                 Ces (h,T) sont calcules par CAT.
!
! - DFLUX :       Le calcul des faces a flux impose (pompage) se fait en imposant 
!                 le flux calcule par CAT.
!
! - UVARM :       Cette subroutine permet de recuperer la temperature solide calculee 
!                  par ABAQUS aux differents points d'integration (ou aux noeuds).
!                 Ces temperatures solides vont permettre de calculer 
!                 les temperatures des faces externes pour CAT.
!
! - UEXTERNALDB : Cette subroutine permet d'interagir avec ABAQUS a differents 
!                 instants de l'execution du calcul.
! 
! ***********************************************************************************************************************
!
!
!
! ***********************************************************************************************************************
!
! Auteur : Flore MOLENDA - INCKA Departement SIMULOG 
! 
!
! Date : Octobre 2010
!
! Version v04r00
!
!
! ************************************************************************************************************************
!
! **************************************************************************
! **************************************************************************
! **************************************************************************
! **************************************************************************
! **************************************************************************



      SUBROUTINE FILM(H,SINK,TEMP,KSTEP,KINC,TTIME,NOEL,NPT,COORDS,
     &                JLTYP,FIELD,NFIELD,SNAME,NODE,AREA)
!
!     Cette subroutine FILM permet d'imposer sur la face solide ABAQUS  
!     (NOEL,JLTYP-10) en cours de calcul le couple (HFace,Tzone) determine par CAT.
!     Cette routine recherche la temperature de la zone TZone et le
!     coeffficient d'echange HFace correspondant a la face num_face 
!     de l'element NOEL
!     Auparavant, elle fait eventuellement appel a RunCorrectTransiAbacat
!     pour appliquer la phase de correction du schema predicteur-correcteur
!
!     Ajout 07/02/2008
!        Stockage des flux de convection aux points des faces externes
!        NB : calcul de la val moyenne du flux par face à LOP=1 dans UEXTERNALDB
!        Edition de ces resultats dans le fichier RCA
!
!######################################################################
!	Partie 1: appel des modules et des includes
!######################################################################
!
      use Mod_AbacatData

      INCLUDE 'aba_param.inc'

!######################################################################
!	Partie 2: déclaration et définition des commons
!######################################################################

!######################################################################
!	Partie 3: définition des variables
!######################################################################

      dimension H(2),TTIME(2),COORDS(3),FIELD(NFIELD)
	character*80 SNAME, CPNAME

	integer(ENTIER) :: EltNum,FaceIdx,FaceNum,FaceID,ZoneIdx
	integer(ENTIER) :: NbFaceConvect
	real(REEL) :: HFace, TZone, Ks, Fact, DTtrTTFi,TZ,HZone
	real(REEL) :: ConvectFlux,Tfluide

!######################################################################
!	Partie 4: imposition des films (H,T)
!######################################################################

      H(1) = 0.0d0
	H(2) = 0.0d0
	SINK = 24.85 ! en Celsius
	ConvectFlux = 0.0d0

c     Si le fichier cca de CAT n'existe pas, on ne fait rien
      if (.not.FileCAT_exist) RETURN
c     Si on n'a pas encore lu les donnees CAT, on ne fait rien
	if (LECT == 0) RETURN

!     Pour l'application de la phase correctrice du schema predicteur-correcteur
!     En stabilise : Theta_cat = 0.d0 car DeltaT_cat = 0 donc FlagCalcTheta = false !!
!     Ou bien en transitoire si on ne veut pas appliquer le schema
      if (FlagPredict) then !calcul de la phase de correction demande
c        mise a jour du temps de calcul abaqus
	   temps_abaqus = Real(TTIME(2),REEL)
c        mise a jour du temps cat
	   temps_cat = temps_abaqus - temps_init
c	   application de la phase de correction
	   call RunCorrectTransiAbacat()

	endif

!     On cherche les coeff echange et temperature associes 
!     à la face num_face de l'élément NOEL

c     Numero de l'element
      EltNum = NOEL
c     Numero de la face sur l'element
      FaceID = JLTYP-10
c     Conversion index de face convention INCKA
	FaceID = ABS(CATToINCKAFaceIndex(EltNum,FaceID,EltVec))

	! Numero global de la face
	FaceNum = EltFaceNumber(EltNum,FaceID)
	! Index de la face FaceNum dans le vecteur des faces externes FaceVec
	FaceIdx = GetFaceExtDataVectorIndex(FaceVec,FaceNum)

	! Coefficient de correction Ks  sur la surface de la face
	Ks = GetFaceExtDataKs(FaceVec%P(FaceIdx))
	! Aire de la face avec prise en compte du coeff Ks
	Area = GetFaceExtDataArea(FaceVec%P(FaceIdx))
	! Ecart temp totale et temp totale relative pour la face
	DTtrTTFi = GetFaceExtDataDTtrTT(FaceVec%P(FaceIdx))

c     Determination du coeff d'echange et de la temperature fluide
c      if ((OLD_METHOD).and.
c     &  (.not.IsZoneGEFluidZoneData(ZoneVec%P(ZoneIdx)))) then
c         ! Avec l'ancienne methode, pour les zones non GE
c         ! Coeff d'echange moyen de la zone
c         HFace = RVectorValue(FluidZoneAlpha,ZoneIdx)
c	else
         ! Avec la nouvelle methode ou pour les zones GE
         ! Coeff d'echange de la face

c 19/09/07 : en fait dans THBN pour les calculs de flux sur le solide
c     THBN utilise le coeff d'echange par face
      HFace = RVectorValue(FaceExtAlpha,FaceIdx)
c	endif

	! Nbre de zones en convection avec la face
	NbFaceConvect = FaceExtDataConvectZoneIDLen(FaceVec%P(FaceIdx))
      !Cas par defaut : une seule zone de convection
      ! ID de la zone en convection avec la face
      ZoneIdx = GetFaceExtDataConvectZoneID(FaceVec%P(FaceIdx),1_ENTIER)
      ! Temperature totale de la zone
      TZone = RVectorValue(FluidZoneTemp,ZoneIdx)
      
      if (NbFaceConvect == 2) then
      !Cas ou la face est en convection avec deux zones
          TFluide = 0.0_REEL
          do iz=1,NbFaceConvect
	      ! ID de la zone en convection avec la face
	      ZoneIdx = GetFaceExtDataConvectZoneID(FaceVec%P(FaceIdx),iz)
	      ! Alpha et tempeerature de zone
            HZone = RVectorValue(FluidZoneAlpha,ZoneIdx)
            TZ = RVectorValue(FluidZoneTemp,ZoneIdx)
            Tfluide = Tfluide + HZone*TZ
          enddo
          if (HFace /= 0.0_REEL) then
             TZone = TFluide/HFace
          endif
      endif
	! Temperature totale relative de la zone par rapport a la face
	TZone = TZone + DTtrTTFi

c     Correction du coefficient d'echange pour tenir compte 
c     du coeff Ks sur l'aire de la face
	HFace = HFace*Ks
	
      ! Flux de convection total (on multiplie par l'aire et on divise par Ks car 
	!  l'aire de la face tient deja compte du coeff Ks)
	ConvectFlux = HFace*Area/Ks*(TZone - TEMP)
	! Affectation de cette valeur dans ConvectFaceFlux au point NPT
	! Verification
	! Nombre de points de la face
	NbNPT = RVectorLen(ConvectFaceFlux%Col(FaceIdx))
	if ((NPT > NbNPT).or.(NPT <= 0)) then
	   write(STDERR_UNIT,*) 
     &         "Nombre de points alloues sur la face : ",NbNPT
         write(STDERR_UNIT,*) 
     &         "Numero du point courant indique par FILM : ",NPT
         call MStop("User Sub FILM",
     & "Affectation du flux de convection impossible en ce point.
     & Revoir le dimensionnement de ConvectFaceFlux ?")
	endif
      ! Affectation de la valeur du flux au point courant de la face
	call SetRMatrixElt(ConvectFaceFlux,NPT,FaceIdx,ConvectFlux,.TRUE.)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     SORTIES de FILM pour ABAQUS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!     Affectation des sorties de resultats vers ABAQUS
!     Application d'une rampe d'amplitude pour les calculs stabilises
!     Pour un calcul stabilise : le temps final du step est toujours 1.0
!     Donc pour obtenir la rampe d'amplitude allant du temps 0 au temps 1
!     il suffit d'utiliser le temps courant du STEP TTIME(1)

      Fact = 1.0_REEL
	if (PERM) Fact = REAL(TTIME(1),REEL)
c     cas du nouveau jeu de donnees : en stabilise il y a 2 STEP
c     sur le second step, il ne faut pas appliquer la rampe d'amplitude
	if (PERM.and.(.not.Old_CATData).and.(KSTEP>1)) Fact = 1.0_REEL

      H(1) = HFace*Fact
      H(2) = 0.0d0*Fact
      SINK = Tzone

      RETURN
      END SUBROUTINE FILM



! **********************************************************************************
! **********************************************************************************
! **********************************************************************************
! **********************************************************************************
! **********************************************************************************

      SUBROUTINE DFLUX(FLUX,SOL,KSTEP,KINC,TTIME,NOEL,NPT,COORDS,
     &                 JLTYP,TEMP,PRESS,SNAME)

!     Cette routine permet d'imposer comme conditions de flux, 
!     pour les elements en pompage, les valeurs de flux calculees
!     par CAT, tenant compte de la porosite.
!     Cette routine recherche les temperatures de zones TZone et les coefficients
!     d'echange HZone correspondant a l'element de pompage NOEL pour calculer
!     ce flux.
!     Auparavant, elle fait eventuellement appel a RunCorrectTransiAbacat
!     pour appliquer la phase de correction du schema predicteur-correcteur
!
!     Ajout Juillet 2007
!     Stockage des valeurs des flux de pompage aux points des elements en pompage
!     Transfert de ce resultat dans UVARM
!
!######################################################################
!	Partie 1: appel des modules et des includes
!######################################################################

      use Mod_AbacatData

      INCLUDE 'aba_param.inc'

!######################################################################
!	Partie 2: déclaration et définition des commons
!######################################################################

!######################################################################
!	Partie 3: définition des variables
!######################################################################

      dimension COORDS(3),FLUX(2),TTIME(2)
      character(80) :: SNAME,CPNAME

	integer(ENTIER) :: EltNum, EltIdx, PompZoneID, NbPompZones,i
	integer(ENTIER) :: PtNum
	real(REEL) :: HZone, TZone,Poro,Fact,TotFlux,Kv,DTtrTTE,vol
	Type(SolidEltData) :: Elt

!######################################################################
!	Partie 4: calcul des densités volumiques de flux de pompage
!######################################################################

c      Initialisations
      call InitSolidEltData(Elt)

c     Si le fichier cca de CAT n'existe pas, on ne fait rien
      if (.not.FileCAT_exist) RETURN
c     Si on n'a pas encore lu les donnees CAT, on ne fait rien
	if (LECT == 0) RETURN

!     Pour l'application de la phase correctrice du schema predicteur-correcteur
!     En stabilise : Theta_cat = 0.d0 car DeltaT_cat = 0 !!
!     Ou bien en transitoire si on ne veut pas appliquer le schema
      if (FlagPredict) then !calcul de la phase de correction demande
c        mise a jour du temps de calcul abaqus
	   temps_abaqus = Real(TTIME(2),REEL)
c        mise a jour du temps cat
	   temps_cat = temps_abaqus - temps_init
c	   application de la phase de correction
	   call RunCorrectTransiAbacat()

	endif

!     On cherche les coeff echange et temperature associes 
!     à l'élément de pompage NOEL

      ! Numero du noeud / point d'integration
      PtNum = NPT
      ! Numero de l'element
      EltNum = NOEL
	! Index de l'element EltNum dans le vecteur des elements solides EltVec
	EltIdx = GetSolidEltDataVectorIndex(EltVec,EltNum)

	! Definition de l'element solide
	! par extraction de cet element a partir du vecteur EltVec
	call GetSolidEltDataVectorElt_Idx(EltVec,EltIdx,Elt)

	! Nombre de zones de pompage de l'element
	NbPompZones = GetSolidEltDataVectorZPompIDLen(EltVec,EltIdx)
	! Coefficient Kv de l'element (coeff multiplicatif sur le volume de l'element)
	Kv = GetSolidEltDataKv(Elt)

c     Si cet element n'est pas en pompage, on ne fait rien
	if (NbPompZones == 0_ENTIER) RETURN ! ou generer erreur fatale !!

      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     SORTIES de DFLUX pour ABAQUS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      FLUX(1) = 0.0d0
	FLUX(2) = 0.0d0

	! Boucle sur les zones de pompage de l'element NOEL
	do i=1,NbPompZones
         ! ID de la zone de pompage
	   PompZoneID = GetSolidEltDataZonePompID(Elt,i)
	   ! Porosite de l'element par rapport a la zone courante
	   Poro = GetSolidEltDataPoro(Elt,i)

	   ! Ecart temp totale et temp totale relative pour l'element
	   ! par rapport a la zone de pompage n°i
	   DTtrTTE = GetSolidEltDataDTtrTTE(Elt,i)

         ! Coefficient d'echange de la zone de pompage
         HZone = RVectorValue(FluidZoneAlpha,PompZoneID)

         ! Temperature totale de la zone
         TZone = RVectorValue(FluidZoneTemp,PompZoneID)
	   ! Temperature totale relative de la zone par rapport a l'element
	   TZone = TZone + DTtrTTE

!     FLUX(1) représente le flux par unité de volume
!     FLUX(1)=h.Poro.Kv.(Tzone-Tsolide)

         FLUX(1) = FLUX(1) + Kv*HZone*Poro*(Tzone - SOL)

!     FLUX(2) est la dérivée de FLUX(1) par rapport à la température solide
!     FLUX(2) = -h.Kv.Poro

         FLUX(2) = FLUX(2) - Kv*HZone*Poro

	Enddo

	! Valeur totale du flux de pompage pour UVARM
	TotFlux = FLUX(1)

!     Application d'une rampe d'amplitude pour les calculs stabilises
!     Pour un calcul stabilise : le temps final du step est toujours 1.0
!     Donc pour obtenir la rampe d'amplitude allant du temps 0 au temps 1
!     il suffit d'utiliser le temps courant du STEP TTIME(1)

      Fact = 1.0_REEL
	if (PERM) Fact = REAL(TTIME(1),REEL)
c     cas du nouveau jeu de donnees : en stabilise il y a 2 STEP
c     sur le second step, il ne faut pas appliquer la rampe d'amplitude
	if (PERM.and.(.not.Old_CATData).and.(KSTEP>1)) Fact = 1.0_REEL

      FLUX(1) = FLUX(1)*Fact
      FLUX(2) = FLUX(2)*Fact

c     ##############################################################################
	! Stockage pour UVARM des valeurs de flux de convection par pompage
	! de l'element NOEL d'index EltIdx dans EltVec
	! Volume de l'element (corrige du coeff Kv)
	Vol = GetSolidEltDataVol(Elt)
	! Flux total = flux volumique * volume
	TotFlux = TotFlux*Vol/Kv
	! Cette valeur est stockee dans PompEltFlux : pour sortie UVARM
	call SetRMatrixElt(PompEltFlux,PtNum,EltIdx,TotFlux,.TRUE.)

c      write(*,*) "Elt Num ",NOEL
c	write(*,*) "DFLUX - FLUX(1) = ",TotFlux, 
c     &               GetRMatrixElt(PompEltFlux,PtNum,EltIdx,.TRUE.)

	! Liberation memoire
	call ClearSolidEltData(Elt)

      RETURN
      END SUBROUTINE DFLUX



! ****************************************************************************
! ****************************************************************************
! ****************************************************************************
! ****************************************************************************
! ****************************************************************************

      SUBROUTINE UVARM(UVAR,DIRECT,T,TTIME,DTIME,CMNAME,ORNAME,NUVARM,
     &                 NOEL,NPT,NLAYER,NSPT,KSTEP,KINC,NDI,NSHR,COORD,
     &                 JMAC,JMATYP,MATLAYO, LACCFLA)

!     Cette routine permet de recuperer la temperature du point d'integration 
!     courant et de la stocker dans la variable SolidEltPtTemp(NPT,Idx_Elem(NOEL)).
!     Ce tableau servira a calculer, dans ComputeSolidTemp, les temperatures 
!     moyennes de faces externes et d'elements de pompage
!
!     Cette routine sert egalement a definir les sorties UVARM
!        UVAR(1) :: pour les flux de pompage par element en pompage
!

!######################################################################
!	Partie 1: appel des modules et des includes
!######################################################################

      use Mod_AbacatData
      INCLUDE 'aba_param.inc'

!######################################################################
!	Partie 2: déclaration et définition des commons
!######################################################################

!#####################################################################
!	Partie 3: définition des variables
!######################################################################

      character(80) :: CMNAME,ORNAME,CPNAME
      dimension UVAR(*),TTIME(2),DIRECT(3,3),T(3,3),COORD(*),
     & JMAC(*),JMATYP(*)

      character(3) :: FLGRAY(15)
      dimension ARRAY(15),JARRAY(15)

	integer(ENTIER) :: EltNum,EltIdx,PtNum,i
	real(REEL) :: Temp

!######################################################################
!	Partie 4: récupération en fin d'incrément de la température
!     de masse dans l'élément au point d'intégration
!     considéré dans UVAR(1)
!######################################################################

c     Si le fichier cca de CAT n'existe pas, on ne fait rien
      if (.not.FileCAT_exist) RETURN

c     Initialisations par defaut
      do i=1,NUVARM
         UVAR(i) = 0.0d0
	enddo

c     Recuperation de la temperature dans l'element NOEL
      CALL GETVRM('TEMP',ARRAY,JARRAY,FLGRAY,JRCD,
     &             JMAC,JMATYP,MATLAYO, LACCFLA)

	! Numero de l'element
	EltNum = NOEL
	! Index de l'element EltNum dans EltVec
	EltIdx = GetSolidEltDataVectorIndex(EltVec,EltNum,.TRUE.)
	! Stockage dans CAT uniquement des elements du bord
	if (EltIdx == 0_ENTIER) RETURN
	! Numero du point de l'element
	PtNum = NPT

      ! Affectation de la temperature au point de l'element
	! colonne EltIdx, ligne PtNum
	Temp = ARRAY(1)
	call SetRMatrixElt(SolidEltPtTemp,PtNum,EltIdx,Temp,.TRUE.)

c     ! Flux de pompage de l'element (defini dans DFLUX)
      UVAR(1) = GetRMatrixElt(PompEltFlux,PtNum,EltIdx,.TRUE.)

c      if (UVAR(1) /= 0.0d0) then
c         write(*,*) "Elt Num ",NOEL
c         write(*,*) "UVARM 1 = ",UVAR(1)
c	endif

10100 format("Subroutine UVARM - temps cat = ",f12.5)
10200 format("NOEL = ",i5," NPT = ",i3," Temp = ",f9.3)

      RETURN
      END SUBROUTINE UVARM

! ***************************************************************************
! ***************************************************************************
! ***************************************************************************
! ***************************************************************************
! ***************************************************************************

      SUBROUTINE UEXTERNALDB(LOP,LRESTART,TTIME,DTIME,KSTEP,KINC)

!     Cette routine permet d'intervenir dans ABAQUS, à différents instants du calcul 
!     (en fonction de la valeur LOP).
!
! En début de calcul (LOP=0), on effectue les actions suivantes :
! - Appel a GETJOBNAME et GETOUTDIR pour recuperer le nom du job abaqus
!     et le nom du repertoire de travail
! - Initialisations des donnees de CAT et ABACAT : InitAbacatData
! - Ouverture des fichiers et lecture du fichier inp d'ABAQUS
! - Affichages
!
! En debut d'increment (avant le calcul abaqus) (LOP = 1), on effectue les actions suivantes :
! - Mise a jour de l'instant de calcul abaqus
! - Appel a TestCATNewcomputation : test en debut de STEP si le step correspond a un nouveau
!     calcul et si oui on initialise ce calcul : lecture des données, préparation du calcul etc
!
! Entre LOP = 1 et LOP = 2, ABAQUS appelle UVARM, FILM et DFLUX
!     * UVARM permet de recuperer les valeurs de la temperature solide
!        pour calculer les temperatures des faces et des elements en pompage
!     * FILM et DFLUX permettent d'appliquer les CL thermiques a l'aide des 
!        donnees issues de CAT 
!        Lors d'un calcul transitoire, eventuel appel a RunCorrectTransiAbacat
!
! En fin d'incrément (après le calcul ABAQUS) (LOP=2), on effectue les actions 
!  suivantes :
! - Mise a jour du temps de calcul en transitoire
! - Affichages
! - Calcul des temperatures moyennes sur les elements solides et les faces externes
!     = appel de ComputeSolidTemp
! - Calcul des flux de convection moyen par face externe
!     = appel de ComputeABQFaceHeatFlow
! - Lancement du calcul CAT : appel de ExecuteCAT
! - Application de la phase de prediction pour un calcul transitoire
!     = appel de RunPredictTransiAbacat
!
! En fin de calcul (après la convergence CAT-ABAQUS) (LOP=3), on effectue les actions 
!  suivantes :
! - Affichages
! - Finalisation de l'Ecriture des resultats de CAT
! - Appel de ClearAbacatData (libération mémoire des donnees de ABACAT et de CAT)
! - Fermeture des fichiers CloseAbacatDataFiles
!

!######################################################################
!	Partie 1: appel des modules et des includes
!######################################################################

      use Mod_AbacatData

      INCLUDE 'aba_param.inc'

!######################################################################
!	Partie 2: déclaration des interfaces des routines de CAT
!######################################################################

!######################################################################
!	Partie 3: définition des variables
!######################################################################

      !dimension TTIME(2)
      real*8, dimension(2) :: TTIME
      integer :: i

!######################################################################
!	Partie 4: actions au début de l'analyse
!######################################################################

c     Si le fichier cca de CAT n'existe pas, on ne fait rien
      if ((LOP/=3).and.(.not. FileCAT_exist)) RETURN

      if (LOP == 0) then

      ! Nom du JOB de abaqus = nom du fichier de donnees sans extension
      call GETJOBNAME(JOBNAME,LenJOBNAME)

      ! Repertoire de travail
      call GETOUTDIR(JOBDIR,LenJobDir)

      ! Initialisations (pointeurs nuls) des donnees de ABACAT et de CAT
      call InitAbacatData()

	call PresentExe_ABACAT(EXE_START,VERSION,VERSION_DATE)

      write(*,'(a)') " JOBNAME : ",TRIM(JOBNAME)
	write(*,'(a)') "  JOBDIR : ",TRIM(JOBDIR)
	write(*,*) 
            
	! Ouverture des fichiers et lecture du fichier inp d'ABAQUS
	!write(*,*) "OpenAbacatDataFiles avant"
	call OpenAbacatDataFiles(JOBNAME,JOBDIR)
	!write(*,*) "OpenAbacatDataFiles après"
	if (.not. FileCAT_exist) RETURN

	write(*,*) " INITIALISATIONS POUR CAT EFFECTUEES"

	endif !LOP=0


!######################################################################
!	Partie 5: actions au début de chaque incrément
!######################################################################

      if (LOP == 1) then
c        mise a jout du temps abaqus
         temps_abaqus = Real(TTIME(2),REEL)
c        le nouvel increment/step correspond-il a un nouveau calcul ?
	   call TestCATNewComputation(KSTEP,KINC,temps_abaqus)

      end if !LOP=1


!######################################################################
!	Partie 6: actions à la fin de chaque incrément
!######################################################################

      if (LOP == 2) then

      ! Mise a jour du temps de calcul en transitoire
      if (.not.PERM) then
	   temps_abaqus = Real(TTIME(2),REEL)
         temps_cat = temps_abaqus - temps_init
	endif

c     Affichages pour le suivi du calcul
	if (PERM) then
	   write(*,*)
         write(*,*) 
     &      " CALCUL COUPLE ABAQUS-CAT - ITERATION : ",KINC

	   if (PrintMini()) then
	      write(PrUnit,*)
            write(PrUnit,*) 
     &      " CALCUL COUPLE ABAQUS-CAT - ITERATION : ",KINC
	   endif

	else
	   write(*,*)
         write(*,*) 
     &      " CALCUL COUPLE ABAQUS-CAT - INSTANT (sec) : ",temps_cat

	   if (PrintMini()) then
	      write(PrUnit,*)
            write(PrUnit,*) 
     &      " CALCUL COUPLE ABAQUS-CAT - INSTANT (sec) : ",temps_cat
	   endif

	endif

      ! Calcul des temperatures moyennes des faces externes et des
	! elements de pompage
      call ComputeSolidTemp()

      ! Mise a jour du compteur d'iterations du calcul couple (calcul stabilise)
      if (PERM) then
         COUPLING_IT = KINC
	endif

	! Calcul de CAT
	call ExecuteCAT(.FALSE.,temps_cat,KINC)

      if (PrintMini()) then
	      write(PrUnit,*)
            write(PrUnit,*) 
     &      "DBG RESULTATS CAT - ITERATION : ",KINC
            call WriteCATResults(PrUnit)
	endif
	
      ! Phase de prediction lors d'un calcul transitoire
      if (.not.PERM) then
         call RunPredictTransiAbacat(temps_abaqus,KINC)
      endif

      end if !! fin de if LOP==2

!######################################################################
!	Partie 7: actions à la fin de l'analyse
!######################################################################

      if (LOP == 3) then

      write(*,*)
	write(*,*) " FIN DU CALCUL COUPLE ABAQUS-CAT"
	call PresentExe_ABACAT(EXE_END,VERSION,VERSION_DATE)

c     Petit message a l'ecran en fin de calcul si le calcul abaqus
c     s'est effectue sans couplage avec CAT (car le fichier cca
c     correspondant n'existait pas)
      if (.not. FileCAT_exist) then
	   write(*,*) " >> CE CALCUL ABAQUS A ETE EFFECTUE
     & SANS COUPLAGE AVEC CAT !!"
	   write(*,*) "Pas de fichiers de donnees CAT"
	   write(*,*)
	   RETURN
	endif
      write(*,*)

      if (PrintMini()) then
         write(PrUnit,*) " FIN DU CALCUL COUPLE ABAQUS-CAT"
	   call PresentExe_CAT(PrUnit,EXE_END,PROGRAM_NAME, 
     &                       VERSION,VERSION_DATE)
      endif

!     Finalisation fichier rca : modification du nombre d'instants de calcul
!        dans le cas d'un calcul transitoire uniquement
      if (.not.PERM) then
         call FinalizeRCAFile(RCAFileName,instant_cat)
	endif

	! Fermeture des fichiers
	call CloseAbacatDataFiles()
      ! Liberation memoire des donnees de ABACAT
      call ClearAbacatData()

      end if !LOP=3



!######################################################################
!	Partie 8 : definition des formats
!######################################################################

10001 format(i8,a1,a10,a2,e14.8,a2,e14.8)
10002 format(i8,a1,a10,a2,e14.8,a2,e14.8)

10200 format(F6.0,2F9.3)
10300 format(3F6.0,2F12.5)
10400 format(2F6.0,2F9.3)

10210 format(F6.0,F9.3)
10310 format(3F6.0,F12.5)
10410 format(2F6.0,F9.3)

      RETURN
      END SUBROUTINE UEXTERNALDB


! ***************************************************************************
! ***************************************************************************
! ***************************************************************************
! ***************************************************************************
