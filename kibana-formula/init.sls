#Package.kibana init.sls
{% set kibana = pillar['kibana'] %}

add_kibana_repo:
  pkgrepo.managed:
    - humanname: Kibana Repo {{ kibana['repo'] }}
    - name: deb https://artifacts.elastic.co/packages/{{ kibana['repo'] }}/apt stable main
    - file: /etc/apt/sources.list.d/kibana.list
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch

install_kibana:
  pkg.installed:
    - name: kibana
    - version: {{ kibana['version'] }}
    - hold: {{ kibana['hold'] | default(False) }}
    - require:
      - pkgrepo: add_kibana_repo

{% if salt['pillar.get']('kibana:config') %}
/etc/kibana/kibana.yml:
  file.serialize:
    - dataset_pillar: kibana:config
    - formatter: yaml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: install_kibana
{% endif %}


kibana:
  service.running:
    - restart: {{ kibana['restart'] | default(True) }}
    - enable: {{ kibana['enable'] | default(True) }}
    - require:
      - pkg: install_kibana
    - watch:
      {% if salt['pillar.get']('kibana:config') %}
      - file: /etc/kibana/kibana.yml
      {% endif %}
      - pkg: kibana
