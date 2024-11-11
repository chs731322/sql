-- PL / SQL
-- 데이터베이스에서 사용되는 절차적 언어
-- 프로시저, 함수, 트리거 등의 형태로 작성할 수 있음
-- 데이터 조작 및 비지니스 로직을 데이터베이스 내에서 직접 처리할 수 있음

-- 함수
CREATE OR REPLACE FUNCTION GET_ODD_EVEN(N IN NUMBER)
RETURN VARCHAR2
IS 
	-- 함수에서 사용할 변수를 선언
	MSG VARCHAR2(100);
BEGIN
	-- 실행 영역
	IF N = 0	THEN
		MSG := '0입니다.';
	ELSIF MOD(N, 2) = 0 THEN
		MSG := '짝수입니다.';
	ELSE
		MSG := '홀수입니다.';
	END IF;
	RETURN MSG;
END;

SELECT
	GET_ODD_EVEN(10),
	GET_ODD_EVEN(3),
	GET_ODD_EVEN(-100),
	GET_ODD_EVEN(0)
FROM DUAL;


CREATE OR REPLACE FUNCTION GET_SCORE_GRADE(SCORE IN NUMBER)
RETURN VARCHAR2
IS 
	GRADE VARCHAR2(1);
	USER_EXCEPTION EXCEPTION;
BEGIN 
	IF SCORE < 0 THEN
		RAISE USER_EXCEPTION;
	END IF;
    IF SCORE >= 90 THEN
        GRADE := 'A';
    ELSIF SCORE >= 80 THEN
        GRADE := 'B';
    ELSIF SCORE >= 70 THEN
        GRADE := 'C';
    ELSIF SCORE >= 60 THEN
        GRADE := 'D';
    ELSE
        GRADE := 'F';
    END IF;
	RETURN GRADE;

EXCEPTION
	WHEN USER_EXCEPTION THEN
		RETURN '점수는 0 이상 입력해야 합니다.';
	WHEN OTHERS THEN
		RETURN '알 수 없는 에러 발생';
END;


SELECT 
	GET_SCORE_GRADE(90),
	GET_SCORE_GRADE(81),
	GET_SCORE_GRADE(-76),
	GET_SCORE_GRADE(5)
FROM DUAL;


-- 학과 번호를 받아서 학과명을 리턴하는 함수
CREATE OR REPLACE FUNCTION GET_MAJOR_NAME(V_MAJOR_NO IN VARCHAR2)
RETURN VARCHAR2
IS 
	NAME VARCHAR2(30);
BEGIN 
	SELECT 
		M.MAJOR_NAME INTO NAME
	FROM 
		MAJOR M 
	WHERE 
		M.MAJOR_NO = V_MAJOR_NO;

	RETURN NAME;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN '해당 데이터 없음';
END;

SELECT GET_MAJOR_NAME('13') FROM DUAL;


-- 반복문

CREATE OR REPLACE FUNCTION GET_TOTAL(N1 IN NUMBER, N2 IN NUMBER)
RETURN NUMBER
IS
	TOTAL NUMBER;
	I NUMBER;
BEGIN
	TOTAL := 0;
	I := N1;

/*	-- DO WHILE
	LOOP
		TOTAL := TOTAL + I;
		I := I + 1;
		EXIT WHEN I > N2;
	END LOOP;*/

/*	WHILE(I <= N2)
	LOOP
		TOTAL := TOTAL + I;
		I := I + 1;
	END LOOP;
	
	RETURN TOTAL;*/

	FOR I IN N1 .. N2
	LOOP
		TOTAL := TOTAL + I;
	END LOOP;
	
	RETURN TOTAL;

END;


SELECT GET_TOTAL(1, 100) FROM DUAL;

--------------------------------------------
-- 트리거
-- 데이터베이스에서 발생하는 이벤트에 대한 반응으로 자동으로 실행되는 절차적 SQL
-- INSERT, UPDATE, DELETE 등의 이벤트에 대한 반응으로 실행
-- 테이블에 대한 이벤트가 발생하면 자동으로 실행되는 PL/SQL 블록
-- 트리거는 테이블에 종속적이기 때문에 테이블 생성 후 트리거 생성
---------------------------------------------------------------
CREATE TABLE DATA_LOG(
	LOG_DATE DATE DEFAULT SYSDATE,
	LOG_DETAIL VARCHAR2(1000)
);

-- MAJOR 테이블에 내용이 UPDATE 되면 해당 기록을 저장하는 트리거
CREATE OR REPLACE TRIGGER UPDATE_MAJOR_LOG
	AFTER UPDATE ON MAJOR
FOR EACH ROW
BEGIN
	INSERT INTO DATA_LOG(LOG_DETAIL)
	VALUES(:OLD.MAJOR_NO || '-' || :NEW.MAJOR_NO 
	|| ', ' || :OLD.MAJOR_NAME || '-' || :NEW.MAJOR_NAME);
END;

UPDATE MAJOR SET MAJOR_NAME = '디지털문화컨텐츠학과'
WHERE MAJOR_NO = 'A9';

SELECT * FROM DATA_LOG;

CREATE OR REPLACE TRIGGER INSERT_MAJOR_LOG
	AFTER INSERT ON MAJOR
FOR EACH ROW
BEGIN
	INSERT INTO DATA_LOG(LOG_DETAIL)
	VALUES(:NEW.MAJOR_NO || '-' || :NEW.MAJOR_NAME);
END;

INSERT INTO MAJOR VALUES('C1', '멀티미디어학과');

-- 학과 정보 삭제 시 발동되는 트리거
CREATE OR REPLACE TRIGGER DELETE_MAJOR_LOG
	AFTER DELETE ON MAJOR
FOR EACH ROW
BEGIN
	INSERT INTO DATA_LOG(LOG_DETAIL)
	VALUES(:OLD.MAJOR_NO || '-' || :OLD.MAJOR_NAME);
END;

DELETE FROM MAJOR WHERE MAJOR_NO = 'C1';


----------------------------------------------------------------
-- 트리거 INSERT, UPDATE, DELETE 탐지기
----------------------------------------------------------------
CREATE OR REPLACE TRIGGER MAJOR_TRIGGER
	AFTER 
		INSERT OR UPDATE OR DELETE ON MAJOR
FOR EACH ROW
BEGIN
	IF UPDATING THEN
		INSERT INTO DATA_LOG(LOG_DETAIL)
		VALUES('UPDATE >> ' || :OLD.MAJOR_NO || '-' || :NEW.MAJOR_NO 
		|| ', ' || :OLD.MAJOR_NAME || '-' || :NEW.MAJOR_NAME);
	ELSIF INSERTING THEN
		INSERT INTO DATA_LOG(LOG_DETAIL)
		VALUES('INSERT >> ' || :NEW.MAJOR_NO || '-' || :NEW.MAJOR_NAME);
	ELSIF DELETING THEN
		INSERT INTO DATA_LOG(LOG_DETAIL)
		VALUES('DELETE >> ' || :OLD.MAJOR_NO || '-' || :OLD.MAJOR_NAME);
	END IF;
END;

SELECT * FROM DATA_LOG;

-- 접속한 사용자 확인
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') FROM DUAL;

-- 사용자 생성
CREATE USER C##USER IDENTIFIED BY 1234;
-- resource, connect 권한 부여
GRANT CONNECT, RESOURCE TO C##USER;
ALTER USER C##USER DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;

-- C##USER 계정에 C##SCOTT.MAJOR 테이블에 대한 권한 부여
GRANT 
	INSERT, UPDATE, DELETE, SELECT ON C##SCOTT.MAJOR TO C##USER;


CREATE OR REPLACE TRIGGER MAJOR_TRIGGER
	AFTER 
		INSERT OR UPDATE OR DELETE ON MAJOR
FOR EACH ROW
BEGIN
	IF UPDATING THEN
		INSERT INTO DATA_LOG(LOG_DETAIL)
		VALUES('UPDATE >> ' || :OLD.MAJOR_NO || '-' || :NEW.MAJOR_NO 
		|| ', ' || :OLD.MAJOR_NAME || '-' || :NEW.MAJOR_NAME || ' / ' || SYS_CONTEXT('USERENV', 'SESSION_USER'));
	ELSIF INSERTING THEN
		INSERT INTO DATA_LOG(LOG_DETAIL)
		VALUES('INSERT >> ' || :NEW.MAJOR_NO || '-' || :NEW.MAJOR_NAME || ' / ' || SYS_CONTEXT('USERENV', 'SESSION_USER'));
	ELSIF DELETING THEN
		INSERT INTO DATA_LOG(LOG_DETAIL)
		VALUES('DELETE >> ' || :OLD.MAJOR_NO || '-' || :OLD.MAJOR_NAME || ' / ' || SYS_CONTEXT('USERENV', 'SESSION_USER'));
	END IF;
END;

INSERT INTO C##SCOTT.MAJOR VALUES('C9', '게임학과');
DELETE FROM C##SCOTT.MAJOR WHERE MAJOR_NO = 'C9';

SELECT * FROM DATA_LOG;


--로그를 저장할 테이블
CREATE TABLE BOARD_LOG (
    LOG_ID          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ACTION_TYPE     VARCHAR2(10),
    USER_ID         VARCHAR2(50),
    BOARD_NO         NUMBER,
    POST_TITLE      VARCHAR2(150),
    POST_CONTENT    VARCHAR2(3000),
    BEFORE_TITLE    VARCHAR2(150),
    BEFORE_CONTENT  VARCHAR2(3000),
    ACTION_TIMESTAMP TIMESTAMP DEFAULT SYSTIMESTAMP
);

--게시판 테이블 트리거 생성
-- INSERT, UPDATE, DELETE 에 대응하는 트리거
CREATE OR REPLACE TRIGGER TRG_BOARD_ACTIONS
AFTER
	INSERT OR UPDATE OR DELETE ON BOARD
FOR EACH ROW
DECLARE
	V_USER_ID VARCHAR2(50);
BEGIN
	SELECT 
		SYS_CONTEXT('USERENV','SESSION_USER') INTO V_USER_ID 
	FROM DUAL;

	IF INSERTING THEN
		INSERT INTO 
			BOARD_LOG(
				ACTION_TYPE, USER_ID, BOARD_NO, 
				POST_TITLE, POST_CONTENT)
		VALUES('INSERT', V_USER_ID, :NEW.BNO, 
			:NEW.TITLE, :NEW.CONTENT);
	ELSIF UPDATING THEN
		INSERT INTO 
			BOARD_LOG(
				ACTION_TYPE, USER_ID, BOARD_NO, 
				POST_TITLE, POST_CONTENT,
				BEFORE_TITLE, BEFORE_CONTENT)
		VALUES('UPDATE', V_USER_ID, :NEW.BNO, 
			:NEW.TITLE, :NEW.CONTENT,
			:OLD.TITLE, :OLD.CONTENT);
	ELSIF DELETING THEN
		INSERT INTO 
			BOARD_LOG(
				ACTION_TYPE, USER_ID, BOARD_NO, 
				BEFORE_TITLE, BEFORE_CONTENT)
		VALUES('DELETE', V_USER_ID, :OLD.BNO, 
			:OLD.TITLE, :OLD.CONTENT);
	END IF;
END;
--게시판 테이블에 대한 트리거 테스트
INSERT INTO BOARD(BNO,TITLE, CONTENT, ID) 
VALUES(999999,'제목1','내용1','gouzr6264');
DELETE FROM BOARD WHERE BNO = 999999;
UPDATE BOARD SET TITLE = '제목2', CONTENT = '내용2' WHERE BNO = 999999;

SELECT * FROM BOARD_LOG; 


-------------------------------------------------------------------------
-- 프로시저
-- SQL 쿼리문으로 로직을 조합해서 사용하는 데이터베이스 코드
-- SQL문과 제어문을 이용해서, 데이터를 검색, 삽입, 수정, 삭제를 할 수 있음
-- 결과를 외부로 전달할 수 있음
-- 하나의 트랜잭션 구성 시 사용
-------------------------------------------------------------------------
-- 매개변수가 없는 프로시저
CREATE OR REPLACE PROCEDURE PROCEDURE_EX1
IS
	-- 변수 선언
	TEST_VAR VARCHAR2(100);
BEGIN
	-- 실행부
	TEST_VAR := 'HELLO WORLD';
	DBMS_OUTPUT.PUT_LINE(TEST_VAR);
END;

SET SERVEROUTPUT ON;


-- 프로시저 실행
DECLARE
	-- 변수 선언
BEGIN
	-- 실행부
	PROCEDURE_EX1();
END;

-- 매개변수가 있는 프로시저
-- IN : 입력 매개변수
CREATE OR REPLACE PROCEDURE PROCEDURE_EX2(
	PID IN VARCHAR2, 
	PNAME IN VARCHAR2, 
	AGE IN NUMBER)
IS
	TEST_VAR VARCHAR2(100);
BEGIN
	TEST_VAR := 'HELLO WORLD';
	DBMS_OUTPUT.PUT_LINE(PID || ' ' || PNAME || ' ' || AGE);
	INSERT INTO PERSON VALUES(PID, PNAME, AGE);
	COMMIT; -- 문제가 없을 시 커밋해서 DB에 반영
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR');
		ROLLBACK; -- 문제가 생겼을 경우 롤백
END;

BEGIN
	PROCEDURE_EX2('0003', '콩순이', 20);
END;

SELECT * FROM PERSON;

-- 값을 외부로 전달하는 프로시저
CREATE OR REPLACE PROCEDURE PROCEDURE_EX3(
	NUM IN NUMBER,
	RESULT OUT NUMBER
)
IS
	I NUMBER;
	USER_EXCEPTION EXCEPTION;
BEGIN
	IF NUM <= 0 THEN
		RAISE USER_EXCEPTION;
	END IF;

	-- 반복문을 이용해서 1~NUM까지 곱하는 팩토리얼 계산
	-- 결과값을 RESULT에 저장
	RESULT := 1;

	FOR I IN 1 .. NUM
	LOOP
		RESULT := RESULT * I;
	END LOOP;
	
	DBMS_OUTPUT.PUT_LINE('결과 : ' || RESULT);

	EXCEPTION
	-- 사용자 정의 예외 처리
	WHEN USER_EXCEPTION THEN
		DBMS_OUTPUT.PUT_LINE('숫자는 0보다 커야 합니다.');
		RESULT := -1;

	-- 그 외의 예외 처리
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('알 수 없는 오류가 발생했습니다.');
		RESULT := -1;
END;


DECLARE
	FAC NUMBER;
BEGIN
	PROCEDURE_EX3(5, FAC);
	DBMS_OUTPUT.PUT_LINE(FAC);
END;