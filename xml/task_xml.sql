-- 10.Create xml & xsd for beer description:
-- Корневой  элемент назвать Beer. 
-- Другие элементы: Name – название пива. 
-- Type    – тип пива (темное, светлое, лагерное, живое).
--                 Al  – алкогольное либо нет.
--                 Manufacturer   – фирма-производитель.
--                 Ingredients  (должно быть несколько) – ингредиенты:
--                 вода, солод, хмель, сахар и т.д.
--                 Chars  (должно быть несколько) – характеристики:
--                 кол-во оборотов (только если алкогольное),
--                 прозрачность (в процентах), фильтрованное  либо нет,
--  пищевая ценность (ккал), способ
--                 разлива (объем и материал емкостей)
-- Загрузить  в колонку XMLType c привязанной по XSD схемой
-- Запросить список характеристик для безалкогольного типа.

BEGIN
  DBMS_XMLSCHEMA.registerSchema(
  SCHEMAURL => 'beer.xsd',
    SCHEMADOC => '

<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="http://www.w3schools.com" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="beers" type="w3s:beersType" xmlns:w3s="http://www.w3schools.com"/>
  <xs:complexType name="beersType">
    <xs:sequence>
      <xs:element type="w3s:beerType" name="beer" maxOccurs="unbounded" minOccurs="0" xmlns:w3s="http://www.w3schools.com"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="beerType">
    <xs:sequence>
      <xs:element name="name" type="xs:string">
      </xs:element>
      <xs:element name="type">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:enumeration value="wheat"/>
            <xs:enumeration value="black"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
      <xs:element name="al">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:enumeration value="Y"/>
            <xs:enumeration value="N"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
      <xs:element name="manufacturer" type="xs:string">
      </xs:element>
      <xs:element name="ingredients" type="xs:string">
      </xs:element>
      <xs:element type="w3s:charsType" name="chars" xmlns:w3s="http://www.w3schools.com"/>
    </xs:sequence>
    <xs:attribute type="xs:string" name="id" use="optional"/>
  </xs:complexType>
  <xs:complexType name="charsType">

      <xs:sequence>
      <xs:element name="alcohol_percent"  type="xs:string">
      </xs:element>
      <xs:element name="transparency">
        <xs:simpleType>
          <xs:restriction base="xs:integer">
            <xs:maxExclusive value="100"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
      <xs:element name="filtered">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:enumeration value="N"/>
            <xs:enumeration value="Y"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
      <xs:element name="nutrutional_value" type="xs:integer">
      </xs:element>
      <xs:element type="w3s:bottling_methodType" name="bottling_method" xmlns:w3s="http://www.w3schools.com"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="bottling_methodType">
    <xs:sequence>
      <xs:element name="volume" type="xs:double">
      </xs:element>
      <xs:element name="material">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:enumeration value="glass"/>
            <xs:enumeration value="can"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>
</xs:schema>');
  END;


create table test_xml (
    xml_id number(10) not null,
    xml_data xmltype,
  CONSTRAINT test_xml PRIMARY KEY(xml_id)

);

INSERT INTO test_xml VALUES (1, '
<beers >
    <beer id="1">
        <name>Hoegaarden</name>
        <type>wheat</type>
        <al>Y</al>
        <manufacturer>Anheuser-Busch</manufacturer>
        <ingredients>water, malt, hops</ingredients>
        <chars>
            <alcohol_percent>4.5</alcohol_percent>
            <transparency>50</transparency>
            <filtered>N</filtered>
            <nutrutional_value>500</nutrutional_value>
            <bottling_method>
                <volume>0.3</volume>
                <material>glass</material>
            </bottling_method>
        </chars>
    </beer>
    <beer id="2">
        <name>Leffe</name>
        <type>black</type>
        <al>Y</al>
        <manufacturer>Anheuser-Busch</manufacturer>
        <ingredients>water, malt, hops</ingredients>
        <chars>
            <alcohol_percent>6.5</alcohol_percent>
            <transparency>60</transparency>
            <filtered>Y</filtered>
            <nutrutional_value>600</nutrutional_value>
            <bottling_method>
                <volume>0.3</volume>
                <material>glass</material>
            </bottling_method>
        </chars>
    </beer>
    <beer id="3">
        <name>Stella Artois</name>
        <type>wheat</type>
        <al>N</al>
        <manufacturer>Den Horen</manufacturer>
        <ingredients>water, malt</ingredients>
        <chars>
            <alcohol_percent></alcohol_percent>
            <transparency>30</transparency>
            <filtered>Y</filtered>
            <nutrutional_value>450</nutrutional_value>
            <bottling_method>
                <volume>0.5</volume>
                <material>can</material>
            </bottling_method>
        </chars>
    </beer>
    <beer id="4">
        <name>Beck</name>
        <type>wheat</type>
        <al>N</al>
        <manufacturer>Brauerei Beck</manufacturer>
        <ingredients>water, malt, sugar</ingredients>
        <chars>
            <alcohol_percent></alcohol_percent>
            <transparency>30</transparency>
            <filtered>Y</filtered>
            <nutrutional_value>600</nutrutional_value>
            <bottling_method>
                <volume>0.5</volume>
                <material>glass</material>
            </bottling_method>
        </chars>
    </beer>
    <beer id="5">
        <name>Heineken</name>
        <type>black</type>
        <al>Y</al>
        <manufacturer>Heineken International</manufacturer>
        <ingredients>water, malt, hops, sugar</ingredients>
        <chars>
            <alcohol_percent>5.5</alcohol_percent>
            <transparency>80</transparency>
            <filtered>Y</filtered>
            <nutrutional_value>500</nutrutional_value>
            <bottling_method>
                <volume>0.5</volume>
                <material>glass</material>
            </bottling_method>
        </chars>
    </beer>
</beers>');


SELECT
  x.xml_data.extract('//beer[al/text()=''N'']['||ROWNUM||']/name/text()') ,
  beer.filtered,
  beer.transparency,
  beer.nutritional_value,
  beer.bottling_method_volume,
  beer.bottling_method_material
FROM test_xml x ,
  XMLTABLE('//beer[al/text()=''N'']/chars' PASSING x.XML_DATA COLUMNS filtered VARCHAR2(5) PATH 'filtered',
           transparency NUMBER(3) PATH 'transparency',
           nutritional_value NUMBER(5) PATH 'nutrutional_value',
           bottling_method_volume VARCHAR2(5) PATH 'bottling_method/volume',
           bottling_method_material VARCHAR2(10) PATH 'bottling_method/material') beer where xml_id=1;