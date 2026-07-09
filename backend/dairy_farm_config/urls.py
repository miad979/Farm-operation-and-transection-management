from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/auth/", include("users.urls")),
    path("api/v1/", include("animals.urls")),
    path("api/v1/", include("financial.urls")),
    path("api/v1/dashboard/", include("dashboard.urls")),
    path("api/v1/reports/", include("dashboard.report_urls")),
    path("api/v1/notifications/", include("dashboard.notification_urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
