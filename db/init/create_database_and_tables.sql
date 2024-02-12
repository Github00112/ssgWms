DROP DATABASE SELLPICK;
CREATE DATABASE SELLPICK DEFAULT CHARACTER SET UTF8 COLLATE UTF8_GENERAL_CI;

USE SELLPICK;

# 쇼핑몰(ONLINE MALL)
CREATE TABLE SHOPPING_MALL
(
    ID   INT         NOT NULL,
    NAME VARCHAR(20) NOT NULL COMMENT '쇼핑몰 이름',

    PRIMARY KEY (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '쇼핑몰';

# 상품 브랜드
CREATE TABLE BRAND
(
    ID   INT AUTO_INCREMENT NOT NULL    COMMENT '브랜드 코드',
    NAME VARCHAR(20)        NULL        COMMENT '브랜드 이름',

    PRIMARY KEY (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '상품 브랜드';

# 택배 회사
CREATE TABLE DELIVERY_CMP
(
    ID   INT AUTO_INCREMENT NOT NULL,
    NAME VARCHAR(20)        NOT NULL,

    PRIMARY KEY (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '택배사';

# 사업자
CREATE TABLE BUSINESS_OWNER
(
    ID       INT         NOT NULL,
    EMAIL    VARCHAR(30) NOT NULL   COMMENT '사업자 이메일',
    PASSWORD VARCHAR(20) NOT NULL   COMMENT '사업자 비밀번호',
    NAME     VARCHAR(10) NOT NULL   COMMENT '사업자 이름',
    PHONE    VARCHAR(15) NULL       COMMENT '사업자 전화번호',
    ADDRESS  VARCHAR(20) NULL       COMMENT '사업자 주소',

    PRIMARY KEY (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '사업자';

# 고객
CREATE TABLE CUSTOMER
(
    ID       INT         NOT NULL,
    EMAIL    VARCHAR(30) NOT NULL COMMENT '고객 이메일',
    PASSWORD VARCHAR(20) NOT NULL COMMENT '고객 비밀번호',
    NAME     VARCHAR(10) NOT NULL COMMENT '고객 이름',
    PHONE    VARCHAR(15) NOT NULL COMMENT '고객 전화번호',
    ADDRESS  VARCHAR(50) NOT NULL COMMENT '고객 주소',

    PRIMARY KEY (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '고객';

# 상품 마감 (일)정산
CREATE TABLE SETTLEMENT
(
    ID           INT AUTO_INCREMENT NOT NULL,
    IN_QUANTITY  INT                NOT NULL DEFAULT 0 COMMENT '입고 수량',
    OUT_QUANTITY INT                NOT NULL DEFAULT 0 COMMENT '출고 수량',
    TOTAL_PRICE  INT                NOT NULL DEFAULT 0 COMMENT '정산 금액',
    CREATED_AT   DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 날짜',
    MODIFIED_AT  DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 날짜',

    PRIMARY KEY (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '정산(일)';

# ================================================================================================================================================================

# 창고
CREATE TABLE WAREHOUSE
(
    ID              INT AUTO_INCREMENT  NOT NULL,
    TYPE            VARCHAR(10)         NOT NULL    COMMENT '입고 OR 출고',
    LOCATION        VARCHAR(5)          NULL        COMMENT '창고 위치',

    DELIVERY_CMP_ID INT                 NOT NULL    COMMENT '택배사 ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_WAREHOUSE_DELIVERY_CMP_ID FOREIGN KEY (DELIVERY_CMP_ID) REFERENCES DELIVERY_CMP (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '창고';

# 상품
CREATE TABLE PRODUCTS
(
    ID           INT     NOT NULL,
    STATUS       BOOLEAN NULL           COMMENT '판매 중(Y) OR 판매 중지(N)',
    COST         INT     NULL           COMMENT '원가',
    PRICE        INT     NULL           COMMENT '판매가',

    BRAND_ID     INT     NOT NULL       COMMENT '브랜드 코드(FK)',
    OWNER_ID     INT     NOT NULL       COMMENT '사업자 ID(FK)',
    WAREHOUSE_ID INT     NOT NULL       COMMENT '창고 ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_PRODUCTS_BRAND_ID     FOREIGN KEY (BRAND_ID)      REFERENCES BRAND (ID),
    CONSTRAINT FK_PRODUCTS_OWNER_ID     FOREIGN KEY (OWNER_ID)      REFERENCES BUSINESS_OWNER (ID),
    CONSTRAINT FK_PRODUCTS_WAREHOUSE_ID FOREIGN KEY (WAREHOUSE_ID)  REFERENCES WAREHOUSE (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '상품';

# 창고 쇼핑몰 관계
CREATE TABLE WAREHOUSE_SHOPPING_MALL_RELATIONSHIP (
    ID	            INT	NOT NULL,

    WAREHOUSE_ID	INT	NOT NULL COMMENT '창고 ID(FK)',
    SM_ID	        INT	NOT NULL COMMENT '쇼핑몰 ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_WAREHOUSE_SHOPPING_MALL_RELATIONSHIP_WAREHOUSE_ID FOREIGN KEY (WAREHOUSE_ID)  REFERENCES WAREHOUSE (ID),
    CONSTRAINT FK_WAREHOUSE_SHOPPING_MALL_RELATIONSHIP_SM_ID        FOREIGN KEY (SM_ID)         REFERENCES SHOPPING_MALL (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '창고 쇼핑몰 관계';


# 창고 입출고
CREATE TABLE WAREHOUSE_INSERT_RELEASE
(
    ID          INT AUTO_INCREMENT         NOT NULL,
    AMOUNT      INT                        NOT NULL COMMENT '수량',
    CREATED_AT  DATE                       NOT NULL COMMENT '입고 OR 출고 날짜',
    TYPE        VARCHAR(10)                NOT NULL COMMENT '입고(INSERT) OR 출고(RELEASE)', # TODO : ENUM ('INSERT', 'RELEASE')으로 변경
    TOTAL_PRICE INT                        NOT NULL COMMENT '총 금액',

    PRODUCTS_ID INT                        NOT NULL COMMENT '상품 ID(FK)',
    DEADLINE_ID INT                        NOT NULL COMMENT '마감(일) ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_WAREHOUSE_INSERT_RELEASE_PRODUCTS_ID FOREIGN KEY (PRODUCTS_ID) REFERENCES PRODUCTS (ID),
    CONSTRAINT FK_WAREHOUSE_INSERT_RELEASE_DEADLINE_ID FOREIGN KEY (DEADLINE_ID) REFERENCES SETTLEMENT (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '창고 입출고';

# 발주 관리
CREATE TABLE MGT_ORDERS
(
    ID             INT AUTO_INCREMENT NOT NULL,
    PURCHASER      VARCHAR(10)        NULL                          		COMMENT '매입 거래처',
    AMOUNT         INT                NULL                          		COMMENT '주문 수량',
    CONfIRM        BOOLEAN            NOT NULL DEFAULT FALSE           		COMMENT '발주 확정 여부(Y/N)',
    DATE           DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP 	COMMENT '발주 일자',

    PRODUCTS_ID    INT                NOT NULL                      		COMMENT '상품 ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_MGT_ORDERS_PRODUCTS_ID FOREIGN KEY (PRODUCTS_ID) REFERENCES PRODUCTS (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '발주 관리';

# 쇼핑몰 주문
CREATE TABLE SM_ORDERS
(
    ID                    INT AUTO_INCREMENT NOT NULL,
    AMOUNT                INT                NOT NULL                           COMMENT '주문 수량',
    PAYMENT_AMOUNT        INT                NOT NULL                           COMMENT '결제 금액',
    CREATED_AT            DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '주문 일자',
    EXPECTED_AT           DATETIME           NOT NULL                           COMMENT '예상 배송일',
    SELLER_SEND_STATUS    VARCHAR(20)        NULL                               COMMENT '판매자 발송 상태(배송준비중, 주문 취소, 배송완료)',

    CUSTOMER_ID           INT                NOT NULL                           COMMENT '고객 ID(FK)',
    SHOPPING_MALL_ID      INT                NOT NULL                           COMMENT '쇼핑몰 ID(FK)',
    PRODUCTS_ID           INT                NOT NULL                           COMMENT '상품 ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_SM_ORDERS_CUSTOMER_ID         FOREIGN KEY (CUSTOMER_ID)       REFERENCES CUSTOMER (ID),
    CONSTRAINT FK_SM_ORDERS_SHOPPING_MALL_ID    FOREIGN KEY (SHOPPING_MALL_ID)  REFERENCES SHOPPING_MALL (ID),
    CONSTRAINT FK_SM_ORDERS_PRODUCTS_ID         FOREIGN KEY (PRODUCTS_ID)       REFERENCES PRODUCTS (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '쇼핑몰 주문';

# 운송장
CREATE TABLE WAYBILL
(
    ID              INT AUTO_INCREMENT NOT NULL                             COMMENT '운송장 ID',
    DELIVERY_DATE   DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP   COMMENT '배송 시작 일자',

    ORDERS_ID       INT                NOT NULL                             COMMENT '주문 ID(FK)',
    CUSTOMER_ID     INT                NOT NULL                             COMMENT '고객 ID(FK)',

    PRIMARY KEY (ID),
    CONSTRAINT FK_WAYBILL_ORDERS_ID         FOREIGN KEY (ORDERS_ID)         REFERENCES SM_ORDERS (ID),
    CONSTRAINT FK_WAYBILL_CUSTOMER_ID       FOREIGN KEY (CUSTOMER_ID)       REFERENCES CUSTOMER (ID)
) ENGINE = INNODB DEFAULT CHARSET = UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI
    COMMENT = '운송장';
