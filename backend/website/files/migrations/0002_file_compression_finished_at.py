# Generated by Django 4.2.3 on 2023-08-09 13:53

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("files", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="file",
            name="compression_finished_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
