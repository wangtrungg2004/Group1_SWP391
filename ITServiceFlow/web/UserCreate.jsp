<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Create User - IT ServiceFlow</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,typography"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        primary: "#2563EB",
                        "primary-hover": "#1D4ED8",
                        "background-light": "#F3F4F6",
                        "background-dark": "#0F172A",
                        "surface-light": "#FFFFFF",
                        "surface-dark": "#1E293B",
                        "border-light": "#E5E7EB",
                        "border-dark": "#334155",
                        "text-light": "#111827",
                        "text-dark": "#F8FAFC",
                        "text-muted-light": "#6B7280",
                        "text-muted-dark": "#94A3B8"
                    },
                    fontFamily: {
                        sans: ["Inter", "sans-serif"]
                    },
                    borderRadius: {
                        DEFAULT: "0.375rem"
                    }
                }
            }
        };
    </script>
</head>
<body class="bg-background-light font-sans antialiased text-text-light min-h-screen flex flex-col md:flex-row">
    <div class="md:hidden bg-surface-light border-b border-border-light p-4 flex justify-between items-center sticky top-0 z-20">
        <div class="flex items-center space-x-2">
            <span class="material-icons text-primary text-3xl">dns</span>
            <span class="font-bold text-lg">IT ServiceFlow</span>
        </div>
        <button class="text-text-muted-light"><span class="material-icons">menu</span></button>
    </div>

    <aside class="hidden md:flex w-64 flex-col fixed inset-y-0 left-0 z-10 bg-surface-light border-r border-border-light">
        <div class="h-16 flex items-center px-6 border-b border-border-light">
            <span class="material-icons text-primary text-3xl mr-2">dns</span>
            <span class="font-bold text-xl tracking-tight">IT ServiceFlow</span>
        </div>
        <nav class="flex-1 overflow-y-auto py-6 px-3 space-y-1">
            <a class="flex items-center px-3 py-2 text-sm font-medium rounded-md text-text-muted-light hover:bg-background-light hover:text-primary transition group" href="${pageContext.request.contextPath}/AdminDashboard">
                <span class="material-icons mr-3 text-xl text-gray-400 group-hover:text-primary">dashboard</span>
                Dashboard
            </a>
            <div class="pt-4 pb-2">
                <p class="px-3 text-xs font-semibold text-text-muted-light uppercase tracking-wider">Administration</p>
            </div>
            <a class="flex items-center px-3 py-2 text-sm font-medium rounded-md bg-primary bg-opacity-10 text-primary transition" href="UserManagement">
                <span class="material-icons mr-3 text-xl text-primary">people</span>
                User Management
            </a>
            <a class="flex items-center px-3 py-2 text-sm font-medium rounded-md text-text-muted-light hover:bg-background-light hover:text-primary transition group" href="#!">
                <span class="material-icons mr-3 text-xl text-gray-400 group-hover:text-primary">settings</span>
                Settings
            </a>
        </nav>
        <div class="border-t border-border-light p-4 relative">
            <button id="profileMenuBtn" type="button" class="w-full flex items-center text-left">
                <div class="h-9 w-9 rounded-full bg-gradient-to-tr from-primary to-blue-400 flex items-center justify-center text-white font-bold text-sm">AD</div>
                <div class="ml-3">
                    <p class="text-sm font-medium"><c:out value="${sessionScope.user.fullName}"/></p>
                    <p class="text-xs text-text-muted-light">System Admin</p>
                </div>
                <span class="material-icons ml-auto text-text-muted-light">expand_more</span>
            </button>
            <div id="profileDropdown" class="hidden absolute left-2 right-2 bottom-16 bg-surface-light border border-border-light rounded-md shadow-lg overflow-hidden z-20">
                <div class="px-4 py-3 bg-primary text-white">
                    <p class="font-medium"><c:out value="${sessionScope.user.fullName}"/></p>
                    <p class="text-xs opacity-90">Admin</p>
                </div>
                <a href="#!" class="flex items-center px-4 py-3 text-sm hover:bg-gray-50">
                    <span class="material-icons mr-3 text-base text-gray-500">settings</span>
                    Settings
                </a>
                <a href="#!" class="flex items-center px-4 py-3 text-sm hover:bg-gray-50">
                    <span class="material-icons mr-3 text-base text-gray-500">person_outline</span>
                    Profile
                </a>
                <a href="#!" class="flex items-center px-4 py-3 text-sm hover:bg-gray-50">
                    <span class="material-icons mr-3 text-base text-gray-500">mail_outline</span>
                    My Messages
                </a>
                <a href="Logout" class="flex items-center px-4 py-3 text-sm hover:bg-gray-50">
                    <span class="material-icons mr-3 text-base text-gray-500">logout</span>
                    Logout
                </a>
            </div>
        </div>
    </aside>

    <main class="flex-1 md:ml-64 p-6 md:p-10">
        <nav aria-label="Breadcrumb" class="flex mb-6">
            <ol class="inline-flex items-center space-x-1 md:space-x-3">
                <li class="inline-flex items-center">
                    <a class="inline-flex items-center text-sm font-medium text-text-muted-light hover:text-primary" href="${pageContext.request.contextPath}/AdminDashboard">
                        <span class="material-icons text-base mr-1">home</span>
                        Home
                    </a>
                </li>
                <li>
                    <div class="flex items-center">
                        <span class="material-icons text-text-muted-light text-base">chevron_right</span>
                        <a class="ml-1 text-sm font-medium text-text-muted-light hover:text-primary md:ml-2" href="#!">Users</a>
                    </div>
                </li>
                <li aria-current="page">
                    <div class="flex items-center">
                        <span class="material-icons text-text-muted-light text-base">chevron_right</span>
                        <span class="ml-1 text-sm font-medium md:ml-2">Create New User</span>
                    </div>
                </li>
            </ol>
        </nav>

        <div class="mb-8">
            <h1 class="text-3xl font-bold tracking-tight">Create New User</h1>
            <p class="mt-2 text-sm text-text-muted-light">Add a new user to the organization.</p>
        </div>

        <c:if test="${not empty error}">
            <div class="mb-4 p-3 rounded-md bg-red-100 text-red-700">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="mb-4 p-3 rounded-md bg-green-100 text-green-700">${message}</div>
        </c:if>

        <div class="bg-surface-light rounded-xl shadow-sm border border-border-light overflow-hidden max-w-4xl">
            <div class="px-6 py-4 border-b border-border-light bg-gray-50 flex justify-between items-center">
                <h3 class="text-lg font-medium">User Details</h3>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">Draft</span>
            </div>
            <form action="UserCreate" class="p-6 md:p-8 space-y-6" method="post">
                <div class="grid grid-cols-1 gap-y-6 gap-x-6 sm:grid-cols-2">
                    <div class="sm:col-span-1">
                        <label class="block text-sm font-medium mb-1" for="username">Username <span class="text-red-500">*</span></label>
                        <input class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="username" name="username" placeholder="jdoe" required="" type="text"/>
                    </div>
                    <div class="sm:col-span-1">
                        <label class="block text-sm font-medium mb-1" for="email">Email Address <span class="text-red-500">*</span></label>
                        <input class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="email" name="email" placeholder="john.doe@itserviceflow.com" required="" type="email"/>
                    </div>
                    <div class="sm:col-span-1">
                        <label class="block text-sm font-medium mb-1" for="password">Password <span class="text-red-500">*</span></label>
                        <input class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="password" name="password" required="" type="password"/>
                    </div>
                    <div class="sm:col-span-1">
                        <label class="block text-sm font-medium mb-1" for="confirmPassword">Confirm Password <span class="text-red-500">*</span></label>
                        <input class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="confirmPassword" name="confirmPassword" required="" type="password"/>
                    </div>
                    <div class="sm:col-span-2">
                        <label class="block text-sm font-medium mb-1" for="fullName">Full Name</label>
                        <input class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="fullName" name="fullName" placeholder="John Doe" type="text"/>
                    </div>
                    <div class="sm:col-span-1">
                        <label class="block text-sm font-medium mb-1" for="role">Role <span class="text-red-500">*</span></label>
                        <select class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="role" name="role" required>
                            <option disabled="" selected="" value="">Select a role...</option>
                            <option value="Admin">Admin</option>
                            <option value="IT Support">IT Support</option>
                            <option value="Manager">Manager</option>
                            <option value="User">User</option>
                        </select>
                    </div>
                    <div class="sm:col-span-1">
                        <label class="block text-sm font-medium mb-1" for="department">Department <span class="text-xs text-text-muted-light">(Optional)</span></label>
                        <input class="block w-full sm:text-sm border-border-light rounded-md h-10 px-3" id="department" name="department" placeholder="e.g. Finance" type="text"/>
                    </div>
                </div>
                <div class="pt-6 flex items-center justify-end space-x-3 border-t border-border-light mt-6">
                    <a class="bg-white py-2 px-4 border border-border-light rounded-md shadow-sm text-sm font-medium hover:bg-gray-50" href="${pageContext.request.contextPath}/AdminDashboard">Cancel</a>
                    <button class="bg-primary border border-transparent rounded-md shadow-sm py-2 px-4 inline-flex justify-center text-sm font-medium text-white hover:bg-blue-700" type="submit">
                        <span class="material-icons text-sm mr-2">save</span>
                        Save User
                    </button>
                </div>
            </form>
        </div>

        <div class="mt-10">
            <h3 class="text-lg font-medium mb-4">Recently Added Users</h3>
            <div class="bg-surface-light shadow overflow-hidden border-b border-border-light sm:rounded-lg">
                <table class="min-w-full divide-y divide-border-light">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-text-muted-light uppercase tracking-wider" scope="col">Username</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-text-muted-light uppercase tracking-wider" scope="col">Email</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-text-muted-light uppercase tracking-wider" scope="col">Role</th>
                        </tr>
                    </thead>
                    <tbody class="bg-surface-light divide-y divide-border-light">
                        <c:forEach var="u" items="${recentUsers}" end="9">
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium"><c:out value="${u.username}"/></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-text-muted-light"><c:out value="${u.email}"/></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm">
                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800"><c:out value="${u.role}"/></span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
    <script>
        const profileBtn = document.getElementById("profileMenuBtn");
        const profileDropdown = document.getElementById("profileDropdown");

        if (profileBtn && profileDropdown) {
            profileBtn.addEventListener("click", function () {
                profileDropdown.classList.toggle("hidden");
            });

            document.addEventListener("click", function (event) {
                const clickedInside = profileBtn.contains(event.target) || profileDropdown.contains(event.target);
                if (!clickedInside) {
                    profileDropdown.classList.add("hidden");
                }
            });
        }
    </script>
</body>
</html>
