       IDENTIFICATION DIVISION.
       PROGRAM-ID. CARD-VALIDATOR.
       AUTHOR. SUITECRM-COBOL-TEAM.
      ******************************************************************
      * CREDIT CARD VALIDATION USING LUHN ALGORITHM                   *
      * VALIDATES CARD NUMBERS AND IDENTIFIES CARD TYPE               *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CARD-INPUT ASSIGN TO "card-input.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT VALIDATION-OUTPUT ASSIGN TO "card-output.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD  CARD-INPUT.
       01  CARD-INPUT-RECORD.
           05  CI-CARD-NUMBER      PIC X(19).
           05  CI-EXPIRY-MONTH     PIC 99.
           05  CI-EXPIRY-YEAR      PIC 9999.
       
       FD  VALIDATION-OUTPUT.
       01  VALIDATION-OUTPUT-REC   PIC X(200).
       
       WORKING-STORAGE SECTION.
       01  WS-CARD-DATA.
           05  WS-CARD-NUMBER      PIC X(19).
           05  WS-CLEAN-CARD       PIC X(19).
           05  WS-CARD-LENGTH      PIC 99.
           05  WS-EXPIRY-MONTH     PIC 99.
           05  WS-EXPIRY-YEAR      PIC 9999.
       
       01  WS-VALIDATION-RESULT.
           05  WS-IS-VALID         PIC X VALUE 'N'.
           05  WS-CARD-TYPE        PIC X(20).
           05  WS-ERROR-MESSAGE    PIC X(50).
       
       01  WS-LUHN-WORK-AREA.
           05  WS-DIGIT            PIC 9.
           05  WS-DIGIT-IDX        PIC 99.
           05  WS-SUM              PIC 999 VALUE 0.
           05  WS-DOUBLED          PIC 99.
           05  WS-IS-EVEN          PIC 9 VALUE 0.
           05  WS-CHECK-DIGIT      PIC 9.
       
       01  WS-DATE-WORK.
           05  WS-CURRENT-DATE.
               10  WS-CURR-YEAR    PIC 9999.
               10  WS-CURR-MONTH   PIC 99.
               10  WS-CURR-DAY     PIC 99.
       
       01  WS-CARD-PREFIXES.
           05  WS-VISA-PREFIX      PIC X(1) VALUE '4'.
           05  WS-MC-PREFIX-1      PIC X(2) VALUE '51'.
           05  WS-MC-PREFIX-2      PIC X(2) VALUE '52'.
           05  WS-MC-PREFIX-3      PIC X(2) VALUE '53'.
           05  WS-MC-PREFIX-4      PIC X(2) VALUE '54'.
           05  WS-MC-PREFIX-5      PIC X(2) VALUE '55'.
           05  WS-AMEX-PREFIX-1    PIC X(2) VALUE '34'.
           05  WS-AMEX-PREFIX-2    PIC X(2) VALUE '37'.
           05  WS-DISC-PREFIX      PIC X(4) VALUE '6011'.
       
       01  WS-JSON-OUTPUT.
           05  FILLER              PIC X(2) VALUE '{"'.
           05  FILLER              PIC X(7) VALUE 'valid":'.
           05  JSON-VALID          PIC X(5).
           05  FILLER              PIC X(10) VALUE ',"type":"'.
           05  JSON-CARD-TYPE      PIC X(20).
           05  FILLER              PIC X(19) VALUE '","masked_number":"'.
           05  JSON-MASKED-NUM     PIC X(19).
           05  FILLER              PIC X(11) VALUE '","expiry":"'.
           05  JSON-EXPIRY         PIC X(7).
           05  FILLER              PIC X(11) VALUE '","message":"'.
           05  JSON-MESSAGE        PIC X(50).
           05  FILLER              PIC X(2) VALUE '"}' .
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           OPEN INPUT CARD-INPUT
           OPEN OUTPUT VALIDATION-OUTPUT
           
           READ CARD-INPUT
               AT END
                   MOVE 'N' TO WS-IS-VALID
                   MOVE "No input provided" TO WS-ERROR-MESSAGE
                   PERFORM WRITE-ERROR-OUTPUT
               NOT AT END
                   MOVE CI-CARD-NUMBER TO WS-CARD-NUMBER
                   MOVE CI-EXPIRY-MONTH TO WS-EXPIRY-MONTH
                   MOVE CI-EXPIRY-YEAR TO WS-EXPIRY-YEAR
                   PERFORM VALIDATE-CARD
                   PERFORM WRITE-JSON-OUTPUT
           END-READ
           
           CLOSE CARD-INPUT
           CLOSE VALIDATION-OUTPUT
           STOP RUN.
       
       VALIDATE-CARD.
           MOVE 'N' TO WS-IS-VALID
           MOVE SPACES TO WS-ERROR-MESSAGE
           MOVE SPACES TO WS-CARD-TYPE
           
           PERFORM CLEAN-CARD-NUMBER
           PERFORM CHECK-CARD-LENGTH
           
           IF WS-CARD-LENGTH > 0
               PERFORM IDENTIFY-CARD-TYPE
               PERFORM VALIDATE-LUHN
               PERFORM CHECK-EXPIRY-DATE
           END-IF.
       
       CLEAN-CARD-NUMBER.
           MOVE SPACES TO WS-CLEAN-CARD
           MOVE 0 TO WS-CARD-LENGTH
           
           PERFORM VARYING WS-DIGIT-IDX FROM 1 BY 1
               UNTIL WS-DIGIT-IDX > 19
               IF WS-CARD-NUMBER(WS-DIGIT-IDX:1) IS NUMERIC
                   ADD 1 TO WS-CARD-LENGTH
                   MOVE WS-CARD-NUMBER(WS-DIGIT-IDX:1) 
                       TO WS-CLEAN-CARD(WS-CARD-LENGTH:1)
               END-IF
           END-PERFORM.
       
       CHECK-CARD-LENGTH.
           EVALUATE WS-CARD-LENGTH
               WHEN 13 THRU 19
                   CONTINUE
               WHEN OTHER
                   MOVE "Invalid card length" TO WS-ERROR-MESSAGE
           END-EVALUATE.
       
       IDENTIFY-CARD-TYPE.
           EVALUATE TRUE
               WHEN WS-CLEAN-CARD(1:1) = WS-VISA-PREFIX
                   MOVE "VISA" TO WS-CARD-TYPE
               WHEN WS-CLEAN-CARD(1:2) = WS-MC-PREFIX-1 OR
                    WS-CLEAN-CARD(1:2) = WS-MC-PREFIX-2 OR
                    WS-CLEAN-CARD(1:2) = WS-MC-PREFIX-3 OR
                    WS-CLEAN-CARD(1:2) = WS-MC-PREFIX-4 OR
                    WS-CLEAN-CARD(1:2) = WS-MC-PREFIX-5
                   MOVE "MASTERCARD" TO WS-CARD-TYPE
               WHEN WS-CLEAN-CARD(1:2) = WS-AMEX-PREFIX-1 OR
                    WS-CLEAN-CARD(1:2) = WS-AMEX-PREFIX-2
                   MOVE "AMERICAN EXPRESS" TO WS-CARD-TYPE
               WHEN WS-CLEAN-CARD(1:4) = WS-DISC-PREFIX
                   MOVE "DISCOVER" TO WS-CARD-TYPE
               WHEN OTHER
                   MOVE "UNKNOWN" TO WS-CARD-TYPE
           END-EVALUATE.
       
       VALIDATE-LUHN.
           IF WS-ERROR-MESSAGE = SPACES
               MOVE 0 TO WS-SUM
               MOVE 0 TO WS-IS-EVEN
               
               PERFORM VARYING WS-DIGIT-IDX FROM WS-CARD-LENGTH BY -1
                   UNTIL WS-DIGIT-IDX < 1
                   
                   MOVE WS-CLEAN-CARD(WS-DIGIT-IDX:1) TO WS-DIGIT
                   
                   IF WS-IS-EVEN = 1
                       MULTIPLY 2 BY WS-DIGIT GIVING WS-DOUBLED
                       IF WS-DOUBLED > 9
                           SUBTRACT 9 FROM WS-DOUBLED
                       END-IF
                       ADD WS-DOUBLED TO WS-SUM
                   ELSE
                       ADD WS-DIGIT TO WS-SUM
                   END-IF
                   
                   IF WS-IS-EVEN = 0
                       MOVE 1 TO WS-IS-EVEN
                   ELSE
                       MOVE 0 TO WS-IS-EVEN
                   END-IF
               END-PERFORM
               
               DIVIDE WS-SUM BY 10 GIVING WS-DIGIT 
                   REMAINDER WS-CHECK-DIGIT
               
               IF WS-CHECK-DIGIT = 0
                   MOVE 'Y' TO WS-IS-VALID
               ELSE
                   MOVE 'N' TO WS-IS-VALID
                   MOVE "Failed Luhn check" TO WS-ERROR-MESSAGE
               END-IF
           END-IF.
       
       CHECK-EXPIRY-DATE.
           IF WS-IS-VALID = 'Y'
               MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE
               
               IF WS-EXPIRY-YEAR < WS-CURR-YEAR
                   MOVE 'N' TO WS-IS-VALID
                   MOVE "Card expired" TO WS-ERROR-MESSAGE
               ELSE
                   IF WS-EXPIRY-YEAR = WS-CURR-YEAR
                       IF WS-EXPIRY-MONTH < WS-CURR-MONTH
                           MOVE 'N' TO WS-IS-VALID
                           MOVE "Card expired" TO WS-ERROR-MESSAGE
                       END-IF
                   END-IF
               END-IF
           END-IF.
       
       WRITE-JSON-OUTPUT.
           IF WS-IS-VALID = 'Y'
               MOVE "true" TO JSON-VALID
               MOVE "Valid card" TO JSON-MESSAGE
           ELSE
               MOVE "false" TO JSON-VALID
               MOVE WS-ERROR-MESSAGE TO JSON-MESSAGE
           END-IF
           
           MOVE WS-CARD-TYPE TO JSON-CARD-TYPE
           
      * Mask card number
           IF WS-CARD-LENGTH > 4
               MOVE WS-CLEAN-CARD(1:4) TO JSON-MASKED-NUM(1:4)
               MOVE "-XXXX-XXXX-" TO JSON-MASKED-NUM(5:11)
               COMPUTE WS-DIGIT-IDX = WS-CARD-LENGTH - 3
               MOVE WS-CLEAN-CARD(WS-DIGIT-IDX:4) 
                   TO JSON-MASKED-NUM(16:4)
           ELSE
               MOVE WS-CARD-NUMBER TO JSON-MASKED-NUM
           END-IF
           
           STRING WS-EXPIRY-MONTH DELIMITED BY SIZE
                  "/" DELIMITED BY SIZE
                  WS-EXPIRY-YEAR DELIMITED BY SIZE
                  INTO JSON-EXPIRY
           
           WRITE VALIDATION-OUTPUT-REC FROM WS-JSON-OUTPUT
           END-WRITE.
       
       WRITE-ERROR-OUTPUT.
           MOVE "false" TO JSON-VALID
           MOVE "ERROR" TO JSON-CARD-TYPE
           MOVE "XXXX-XXXX-XXXX-XXXX" TO JSON-MASKED-NUM
           MOVE "00/0000" TO JSON-EXPIRY
           MOVE WS-ERROR-MESSAGE TO JSON-MESSAGE
           WRITE VALIDATION-OUTPUT-REC FROM WS-JSON-OUTPUT
           END-WRITE.