from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^index$', views.index, name='index'),
    url(r'^signup/$', views.signup, name = 'signup'),
    url(r'^map/$', views.map, name = 'map'),
    url(r'^qrtest/$', views.qrtest, name = 'qrtest'),
    url(r'^manage_priviliges/$', views.manage_priviliges, name ='manage_priviliges'),
]
