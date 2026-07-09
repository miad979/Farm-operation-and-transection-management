from django.urls import path

from .notifications import NotificationsView

urlpatterns = [
    path("", NotificationsView.as_view(), name="notifications"),
    path("unread/", NotificationsView.as_view(), name="notifications-unread"),
]
