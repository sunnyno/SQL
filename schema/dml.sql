INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(1, NULL, 'Юридическим лицам');
INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(2, NULL, 'Физическим лицам');
INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(3, 1, 'Образцы договоров');
INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(4, 1, 'Банковские реквизиты');
INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(5, 2, 'Схема проезда к офису');
INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(6, 2, 'Почта и телефон');
INSERT INTO TASK_SITE.pages (p_id, p_parent, p_name) VALUES(7, 3, 'Договоры оптовых закупок');


INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(1, 'http://tut.by', 200, 20, 'TUT.BY', NULL);
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(2, 'http://tut.by', 200, 300, NULL, 'tutby.png');
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(3, 'http://onliner.by', 50, 45, 'ONLINER.BY', NULL);
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(4, 'http://onliner.by', 50, 1, NULL, 'onlinerby.jpg');
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(5, 'http://google.by', 10, 10, 'GOOGLE.BY', 'googleby.png');
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(6, 'http://google.com', 1, 1, NULL, 'googlecom.png');
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(7, 'http://habrahabr.ru', 999, 997, '', 'habrahabrru.png');
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(8, 'http://habrahabr.ru', 50, 49, 'HABRAHABR.RU', NULL);
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(9, 'http://gismeteo.by', 0, 0, 'Погода', NULL);
INSERT INTO TASK_SITE.banners (b_id, b_url, b_show, b_click, b_text, b_pic) VALUES(10, 'http://gismeteo.ru', 0, 0, 'Погода', NULL);


INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(1, 1);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(2, 1);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(7, 1);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(1, 2);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(4, 3);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(1, 4);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(2, 4);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(1, 5);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(2, 5);
INSERT INTO TASK_SITE.m2m_banners_pages (b_id, p_id) VALUES(3, 5);

INSERT INTO TASK_SITE.news_categories (nc_id, nc_name) VALUES(1, 'Финансы');
INSERT INTO TASK_SITE.news_categories (nc_id, nc_name) VALUES(2, 'Законодательство');
INSERT INTO TASK_SITE.news_categories (nc_id, nc_name) VALUES(3, 'Логистика');
INSERT INTO TASK_SITE.news_categories (nc_id, nc_name) VALUES(4, 'Строительство');

INSERT INTO TASK_SITE.news (n_id, n_category, n_header, n_text, n_dt) VALUES(1, 1, 'Состояние валютного рынка', '<to be added>', TIMESTAMP '2012-12-03 04:15:27');
INSERT INTO TASK_SITE.news (n_id, n_category, n_header, n_text, n_dt) VALUES(2, 3, 'Контрабанда железобетонных плит', '<to be added>',TIMESTAMP  '2011-09-14 06:19:08');
INSERT INTO TASK_SITE.news (n_id, n_category, n_header, n_text, n_dt) VALUES(3, 3, 'Почта России: вчера, сегодня и снова вчера', ' ',TIMESTAMP  '2011-08-17 09:06:30');
INSERT INTO TASK_SITE.news (n_id, n_category, n_header, n_text, n_dt) VALUES(4, 3, 'Самолётом или поездом?', '<to be added>',TIMESTAMP  '2012-12-20 06:11:42');
INSERT INTO TASK_SITE.news (n_id, n_category, n_header, n_text, n_dt) VALUES(5, 3, 'Куда всё катится?', '<to be added>',TIMESTAMP  '2012-12-11 04:36:17');

INSERT INTO TASK_SITE.reviews_categories (rc_id, rc_name) VALUES(1, 'Технологии');
INSERT INTO TASK_SITE.reviews_categories (rc_id, rc_name) VALUES(2, 'Товары и услуги');

INSERT INTO TASK_SITE.reviews (r_id, r_category, r_header, r_text, r_dt) VALUES(1, 1, 'Роботы на страже строек', '<empty>',TIMESTAMP  '2011-10-03 05:17:37');
INSERT INTO TASK_SITE.reviews (r_id, r_category, r_header, r_text, r_dt) VALUES(2, 1, 'Когда всё это кончится?!', 'Никогда!', TIMESTAMP '2012-12-12 06:31:13');


COMMIT;


--chcp 1251
--set nls_lang = .AL32UTF8