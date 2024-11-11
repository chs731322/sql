-- 제약 조건
SELECT * FROM USER_CONSTRAINTS;

-- 기본 키
ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명 PRIMARY KEY(기본 키로 지정할 컬럼);

CREATE TABLE PERSON(
	PID CHAR(4),
	PNAME VARCHAR2(30 BYTE),
	AGE NUMBER(3,0)
	--CONSTRAINT PERSON_PID_PK PRIMARY KEY(PID)
);

ALTER TABLE PERSON ADD CONSTRAINT PERSON_PID_PK PRIMARY KEY(PID);
-- 샘플 데이터
INSERT INTO PERSON VALUES('0001','홍길동',20);
INSERT INTO PERSON VALUES('0002','김길동',30);
INSERT INTO PERSON VALUES('0003','이길동',40);
INSERT INTO PERSON VALUES('0004','박길동',50);

-- 외래 키
ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명 
FOREIGN KEY(외래키 지정할 컬럼명) 
REFERENCES 외래키로 연결될 테이블명(참조할 테이블의 기본키)
[ON DELETE CASCADE] | [ON DELETE RESTRICT] | [ON DELETE SET NULL];


CREATE TABLE PERSON_ORDER(
	P_ORDER_NO NUMBER(5),
	P_ORDER_MEMO VARCHAR2(300),
	PID CHAR(4)
);

-- PERSON_ORDER에 P_ORDER_NO를 기본 키로 작성
ALTER TABLE PERSON_ORDER ADD CONSTRAINT PERSON_ORDER_PO_NO_PK PRIMARY KEY(P_ORDER_NO);

-- PERSON_ORDER에 PID를 외래키 설정, PERSON에 있는 PID와 연결
ALTER TABLE PERSON_ORDER ADD CONSTRAINT PERSON_ORDER_PID_FK
FOREIGN KEY(PID)
REFERENCES PERSON(PID); -- ON DELETE RESTRICT


INSERT INTO PERSON_ORDER VALUES(1, '지시 내용', '0001');
INSERT INTO PERSON_ORDER VALUES(2, '지시 내용', '0002');
INSERT INTO PERSON_ORDER VALUES(3, '지시 내용', '0003');

-- 에러, PERSON 테이블에 해당 PID 값이 없을 때 --> 참조 무결성
INSERT INTO PERSON_ORDER VALUES(4, '지시 내용', '0005');

-- PERSON 테이블에 PID가 0001인 데이터를 삭제 -> RESTRICT는 자식 레코드가 있으면 멈춤
DELETE FROM PERSON WHERE PID LIKE '0001';

-- 부모 레코드를 지우기 전에 자식 레코드를 먼저 삭제
DELETE FROM PERSON_ORDER WHERE PID LIKE '0001';

-- PERSON_ORDER에 외래키 제약 조건 삭제
ALTER TABLE PERSON_ORDER DROP CONSTRAINT PERSON_ORDER_PID_FK;

-- 외래키 지정 시 ON DELETE CASCADE 지정
ALTER TABLE PERSON_ORDER ADD CONSTRAINT PERSON_ORDER_PID_FK
FOREIGN KEY(PID) REFERENCES PERSON(PID) ON DELETE CASCADE;

SELECT * FROM PERSON_ORDER;
DELETE FROM PERSON WHERE PID LIKE '0002';
DELETE FROM PERSON WHERE PID LIKE '0003';

-- 외래키 지정 시 ON DELETE SET NULL 지정
ALTER TABLE PERSON_ORDER ADD CONSTRAINT PERSON_ORDER_PID_FK
FOREIGN KEY(PID) REFERENCES PERSON(PID) ON DELETE SET NULL;

-- PERSON 테이블 삭제
DROP TABLE PERSON CASCADE CONSTRAINTS;

-- STUDENT 테이블의 학과 번호를 외래키로 지정, MAJOR의 테이블의 학과 번호로 지정
ALTER TABLE STUDENT ADD CONSTRAINT STUDENT_MAJOR_NO_FK
FOREIGN KEY(MAJOR_NO) REFERENCES MAJOR(MAJOR_NO) ON DELETE CASCADE;

-- 기본키
ALTER TABLE MAJOR ADD CONSTRAINT MAJOR_MAJOR_NO_PK
PRIMARY KEY(MAJOR_NO);

SELECT S.*, M.MAJOR_NO 
FROM STUDENT S LEFT OUTER JOIN MAJOR M ON S.MAJOR_NO = M.MAJOR_NO
WHERE M.MAJOR_NO IS NULL;

-- 장학금 테이블 학번 외래키 지정
ALTER TABLE STUDENT_SCHOLARSHIP ADD CONSTRAINT STUDENT_SCHOLARSHIP_STD_NO_FK
FOREIGN KEY(STD_NO) REFERENCES STUDENT(STD_NO) ON DELETE CASCADE;

-- CHECK 제약 조건
-- 컬럼에 들어올 값의 범위 및 제약 조건을 거는 방법
-- ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명 CHECK(조건식);
SELECT * FROM PERSON;
INSERT INTO PERSON VALUES('0001','홍길동',50);
INSERT INTO PERSON VALUES('0002','홍길동',-50);

-- PERSON 테이블에 나이가 0보다 큰 값만 저장되도록 제약 조건 설정
ALTER TABLE PERSON ADD CONSTRAINT PERSON_AGE_CHK CHECK(AGE > 0);
-- 특정 제약 조건을 비활성화
ALTER TABLE PERSON DISABLE CONSTRAINT PERSON_AGE_CHK;
-- 특정 제약 조건을 활성화 -> 다시 활성화할 때 제약 조건 다시 체크
ALTER TABLE PERSON ENABLE CONSTRAINT PERSON_AGE_CHK;
-- 제약 조건 삭제
ALTER TABLE PERSON DROP CONSTRAINT PERSON_AGE_CHK;

-- PERSON 테이블에 데이터 추가 시 이름에 공백이 들어가지 않도록 제약 조건을 설정
ALTER TABLE PERSON ADD CONSTRAINT PERSON_PNAME_CHK CHECK(PNAME NOT LIKE '% %');
ALTER TABLE PERSON ADD CONSTRAINT PERSON_PNAME_CHK CHECK(INSTR(PNAME, ' ')= 0);
INSERT INTO PERSON VALUES('0003', '홍 철수', 11);

-- 학생 테이블에 평점이 0.0~4.5까지만 저장되도록 제약 조건 추가
ALTER TABLE STUDENT ADD CONSTRAINT STUDENT_SCORE_CHK CHECK(STD_SCORE BETWEEN 0 AND 4.5);