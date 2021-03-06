#include "CTRL_OPTIONS.h"


      subroutine optim_readparms(
     I                            mythid
     &                          )

c     ==================================================================
c     SUBROUTINE optim_readparms
c     ==================================================================
c
c     o Initialise the optimization part of the ECCO release.
c
c     started: Christian Eckert eckert@mit.edu 03-Mar-2000
c
c     changed:
c
c     ==================================================================
c     SUBROUTINE optim_readparms
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"

#include "optim.h"

c     == routine arguments ==

      integer mythid

c     == local variables ==

      integer errio
      integer il
      integer iUnit

      character*(max_len_prec) record
      character*(max_len_mbuf) msgbuf

c     == external ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

c--   Optimization parameters.
      namelist /optim/
     &                 optimcycle, nvars,
     &                 nondimcontrol,
     &                 numiter, nfunc, fmin, iprint,
     &                 epsf, epsx, epsg,
     &                 nupdate, eps

      IF ( .NOT.useCTRL ) THEN
C-    pkg CTRL is not used
        _BEGIN_MASTER(myThid)
C-    Track pkg activation status:
C     print a (weak) warning if data.optim is found
         CALL PACKAGES_UNUSED_MSG( 'useCTRL', ' ', ' ' )
        _END_MASTER(myThid)
        RETURN
      ENDIF

      _BEGIN_MASTER( mythid )

c--     Set default values.
        optimcycle    =   0
        nvars         =  10
        nondimcontrol =  .false.
        numiter       =   0
        nfunc         =   1
        fmin          =   0.0 _d 0
        iprint        =  10
        epsx          =   1.e-6
        epsg          =   1.e-6
        eps           =  -1.e-6
        nupdate       =   0

        WRITE(msgBuf,'(A)') 'OPTIM_READPARMS: opening data.optim'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)

        CALL OPEN_COPY_DATA_FILE(
     I                          'data.optim', 'OPTIM_READPARMS',
     O                          iUnit,
     I                          myThid )

        READ(unit = iUnit, nml = optim)

        WRITE(msgBuf,'(A)')
     &       'OPTIM_READPARMS: finished reading data.optim'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                  SQUEEZE_RIGHT , 1)

#ifdef SINGLE_DISK_IO
        CLOSE(iUnit)
#else
        CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

      _END_MASTER( mythid )

      _BARRIER

      return
      end

