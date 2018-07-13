from typing import Any, Dict

from rest_framework import serializers

from accounts.models import User

USER_FIELDS = (
    'uri',
    'pk',
    'email',
    'first_name',
    'last_name',
    'is_superuser',
    'is_staff',
    'is_active',
    'last_login',
    'created_at',
    'updated_at',
)

CREATE_USER_FIELDS = USER_FIELDS + (
    'password',
    'password_confirm',
)


class UserSerializer(serializers.HyperlinkedModelSerializer):
    uri = serializers.HyperlinkedIdentityField(view_name='auth:users-detail')
    first_name = serializers.CharField(required=True)
    last_name = serializers.CharField(required=True)
    is_superuser = serializers.BooleanField(read_only=True)
    last_login = serializers.DateTimeField(read_only=True)
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
    is_active = serializers.BooleanField(read_only=True)
    is_staff = serializers.BooleanField(read_only=True)

    class Meta:
        model = User
        fields = USER_FIELDS


class FullUserSerializer(UserSerializer):
    is_staff = serializers.BooleanField(read_only=False)


class UserCreateSerializer(UserSerializer):
    password = serializers.CharField(write_only=True)
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = CREATE_USER_FIELDS

    def validate(self, data: Dict[str, Any]) -> Dict[str, Any]:
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords don't match.")
        return data

    def create(self, validated_data: Dict[str, Any]) -> User:
        email = validated_data.pop('email', None)
        password = validated_data.pop('password', None)
        validated_data.pop('password_confirm', None)
        is_staff = validated_data.pop('is_staff', False)
        return User.objects.create_user(email, password, is_staff, **validated_data)


class FullUserCreateSerializer(UserCreateSerializer):
    is_staff = serializers.BooleanField(read_only=False)
