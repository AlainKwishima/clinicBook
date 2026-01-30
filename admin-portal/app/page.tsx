'use client'

import { createClient } from '@/utils/supabase/client'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import {
  LayoutGrid, Search, User, RefreshCcw, Star, Users, CheckCircle, Trophy,
  Clock, CheckCircle2, Kanban, MoreHorizontal, ChevronDown,
  Calendar, Video, ArrowUpRight, ChevronRight, ArrowDownCircle, ArrowUpCircle,
  LogOut, Activity, Building2, FileText, Shield, PieChart
} from 'lucide-react'
import { useEffect, useState } from 'react'

export default function Dashboard() {
  const router = useRouter()
  const supabase = createClient()
  const [stats, setStats] = useState({
    doctors: 0,
    pendingDoctors: 0,
    hospitals: 0,
    patients: 0
  })

  useEffect(() => {
    async function fetchStats() {
      const { count: doctorCount } = await supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'doctor')
      const { count: pendingCount } = await supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'doctor').eq('verification_status', 'pending')
      const { count: hospitalCount } = await supabase.from('clinics').select('*', { count: 'exact', head: true })
      // Assuming 'profiles' also stores patients or there's a separate check. For now let's just count all profiles minus doctors?
      // Or just fetch all.
      const { count: totalProfiles } = await supabase.from('profiles').select('*', { count: 'exact', head: true })

      setStats({
        doctors: doctorCount || 0,
        pendingDoctors: pendingCount || 0,
        hospitals: hospitalCount || 0,
        patients: (totalProfiles || 0) - (doctorCount || 0)
      })
    }
    fetchStats()
  }, [supabase])

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return (
    <div className="min-h-screen bg-background-light dark:bg-background-dark font-body antialiased p-4 md:p-8 transition-colors duration-300">
      <div className="max-w-[1400px] mx-auto bg-surface-light dark:bg-surface-dark rounded-3xl shadow-soft dark:shadow-none dark:border dark:border-gray-700 overflow-hidden flex flex-col xl:flex-row transition-colors duration-300 min-h-[800px]">
        {/* Main Content Area */}
        <div className="flex-1 p-6 md:p-8 xl:pr-0 flex flex-col gap-8">

          {/* Header */}
          <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-primary rounded-xl flex items-center justify-center text-white shadow-lg shadow-blue-500/30">
                <LayoutGrid className="w-6 h-6" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-text-main-light dark:text-text-main-dark">Welcome, Administrator</h1>
                <p className="text-sm text-text-sub-light dark:text-text-sub-dark">Clinic Management Overview</p>
              </div>
            </div>
            <div className="flex items-center gap-4 w-full md:w-auto">
              {/* <div className="relative w-full md:w-64">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                <input 
                  className="w-full pl-10 pr-4 py-2.5 bg-gray-100 dark:bg-gray-700/50 rounded-full border-none focus:ring-2 focus:ring-primary text-sm text-gray-700 dark:text-gray-200 placeholder-gray-400 transition-colors" 
                  placeholder="Search" 
                  type="text" 
                />
              </div> */}
              <button
                onClick={handleSignOut}
                className="w-10 h-10 rounded-full border border-gray-200 dark:border-gray-600 flex items-center justify-center hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors text-gray-600 dark:text-gray-300"
                title="Sign Out"
              >
                <LogOut className="w-5 h-5" />
              </button>
            </div>
          </header>

          <div className="grid grid-cols-1 md:grid-cols-12 gap-6">

            {/* Profile / Admin Card */}
            <div className="md:col-span-4 bg-white dark:bg-gray-800 rounded-3xl p-6 shadow-card border border-gray-100 dark:border-gray-700 flex flex-col items-center text-center relative">
              <button className="absolute top-6 right-6 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200">
                <RefreshCcw className="w-5 h-5" onClick={() => window.location.reload()} />
              </button>
              <h3 className="w-full text-left font-semibold text-text-main-light dark:text-text-main-dark mb-4">Profile</h3>
              <div className="relative w-24 h-24 mb-4">
                {/* Decorative Ring */}
                <svg className="w-full h-full transform -rotate-90">
                  <circle className="dark:stroke-gray-700" cx="48" cy="48" fill="none" r="44" stroke="#f3f4f6" strokeWidth="4"></circle>
                  <circle cx="48" cy="48" fill="none" r="44" stroke="#3B82F6" strokeDasharray="276" strokeDashoffset="20" strokeLinecap="round" strokeWidth="4"></circle>
                </svg>
                <div className="absolute inset-1 rounded-full overflow-hidden border-4 border-white dark:border-gray-800 bg-blue-100 flex items-center justify-center">
                  <span className="text-3xl font-bold text-blue-600">A</span>
                </div>
                <div className="absolute bottom-0 right-0 bg-gray-900 text-white p-1 rounded-full border-2 border-white dark:border-gray-800 flex items-center justify-center w-7 h-7">
                  <Star className="w-3 h-3" />
                </div>
              </div>
              <h2 className="text-lg font-bold text-text-main-light dark:text-text-main-dark">System Administrator</h2>
              <p className="text-sm text-text-sub-light dark:text-text-sub-dark mb-6">Super Admin</p>

              <div className="flex items-center justify-center gap-3 w-full">
                <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gray-50 dark:bg-gray-700/50" title="Total User Base">
                  <Users className="text-blue-500 w-4 h-4" />
                  <span className="text-xs font-semibold dark:text-gray-200">{stats.patients + stats.doctors}</span>
                </div>
                <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gray-50 dark:bg-gray-700/50" title="Verified Doctors">
                  <CheckCircle className="text-green-500 w-4 h-4" />
                  <span className="text-xs font-semibold dark:text-gray-200">{stats.doctors - stats.pendingDoctors}</span>
                </div>
                <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gray-50 dark:bg-gray-700/50" title="Facilities">
                  <Building2 className="text-orange-500 w-4 h-4" />
                  <span className="text-xs font-semibold dark:text-gray-200">{stats.hospitals}</span>
                </div>
              </div>
            </div>

            {/* Stats Cards Column */}
            <div className="md:col-span-8 flex flex-col gap-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 h-full">

                {/* Pending Approvals Card */}
                <div className="rounded-3xl p-6 bg-gradient-to-br from-orange-100 via-pink-100 to-rose-100 dark:from-orange-900/40 dark:via-pink-900/40 dark:to-rose-900/40 flex flex-col justify-between relative overflow-hidden group">
                  <div className="flex justify-between items-start mb-8 relative z-10">
                    <h3 className="font-medium text-gray-800 dark:text-gray-100 leading-tight">Pending<br />Approvals</h3>
                    <div className="w-10 h-10 rounded-full bg-white/60 dark:bg-white/10 backdrop-blur-sm flex items-center justify-center">
                      <Clock className="text-gray-700 dark:text-white w-5 h-5" />
                    </div>
                  </div>
                  <div className="relative z-10">
                    <span className="text-4xl font-bold text-gray-900 dark:text-white block mb-1">{stats.pendingDoctors}</span>
                    <span className="text-xs font-medium text-gray-600 dark:text-gray-300 uppercase tracking-wide">Action Needed</span>
                  </div>
                  <div className="absolute -bottom-10 -right-10 w-32 h-32 bg-orange-300/30 rounded-full blur-2xl group-hover:bg-orange-400/40 transition-colors"></div>
                  <Link href="/doctors" className="absolute inset-0" />
                </div>

                {/* Total Doctors Card */}
                <div className="rounded-3xl p-6 bg-gradient-to-br from-cyan-100 via-blue-100 to-indigo-100 dark:from-cyan-900/40 dark:via-blue-900/40 dark:to-indigo-900/40 flex flex-col justify-between relative overflow-hidden group">
                  <div className="flex justify-between items-start mb-8 relative z-10">
                    <h3 className="font-medium text-gray-800 dark:text-gray-100 leading-tight">Total<br />Doctors</h3>
                    <div className="w-10 h-10 rounded-full bg-white/60 dark:bg-white/10 backdrop-blur-sm flex items-center justify-center">
                      <CheckCircle2 className="text-gray-700 dark:text-white w-5 h-5" />
                    </div>
                  </div>
                  <div className="relative z-10">
                    <span className="text-4xl font-bold text-gray-900 dark:text-white block mb-1">{stats.doctors}</span>
                    <span className="text-xs font-medium text-gray-600 dark:text-gray-300 uppercase tracking-wide">Registered</span>
                  </div>
                  <div className="absolute -bottom-10 -right-10 w-32 h-32 bg-blue-300/30 rounded-full blur-2xl group-hover:bg-blue-400/40 transition-colors"></div>
                  <Link href="/doctors" className="absolute inset-0" />
                </div>
              </div>

              {/* Connected Trackers / Status Bar */}
              <div className="bg-gray-100 dark:bg-gray-800 rounded-2xl p-4 flex flex-col sm:flex-row items-center justify-between gap-4">
                <div>
                  <h4 className="font-semibold text-text-main-light dark:text-text-main-dark text-sm">System Status</h4>
                  <p className="text-xs text-text-sub-light dark:text-text-sub-dark">All services operational</p>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-white dark:bg-gray-700 rounded-full flex items-center justify-center shadow-sm">
                    <Shield className="w-4 h-4 text-green-500" />
                  </div>
                  <div className="w-10 h-10 bg-blue-50 dark:bg-blue-900/30 rounded-full flex items-center justify-center shadow-sm">
                    <Activity className="text-blue-600 dark:text-blue-400 w-4 h-4" />
                  </div>
                  <div className="w-10 h-10 bg-white dark:bg-gray-700 rounded-full flex items-center justify-center shadow-sm">
                    <Trophy className="w-4 h-4 text-yellow-500" />
                  </div>
                  <button className="w-8 h-8 flex items-center justify-center text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 ml-2">
                    <MoreHorizontal className="w-5 h-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Focusing / Chart Section */}
          <div className="flex-1 bg-white dark:bg-gray-800 rounded-3xl p-6 md:p-8 shadow-card border border-gray-100 dark:border-gray-700 flex flex-col">
            <div className="flex justify-between items-start mb-6">
              <div>
                <h3 className="text-lg font-bold text-text-main-light dark:text-text-main-dark">Activity Overview</h3>
                <p className="text-sm text-text-sub-light dark:text-text-sub-dark">Registration analytics</p>
              </div>
              <div className="relative">
                <button className="flex items-center gap-2 text-sm font-medium text-gray-600 dark:text-gray-300 bg-gray-50 dark:bg-gray-700 px-4 py-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors">
                  Range: Last month
                  <ChevronDown className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Mock Chart Area */}
            <div className="relative flex-1 min-h-[250px] w-full chart-grid rounded-xl p-4 flex items-center justify-center bg-gray-50/50">
              <div className="text-center">
                <PieChart className="w-12 h-12 text-gray-300 mx-auto mb-2" />
                <p className="text-sm text-gray-400">Chart data visualization coming soon</p>
              </div>
              {/* Placeholders from HTML if we wanted SVG lines */}
              {/* <div className="absolute inset-0 top-4 bottom-12 left-12 right-4">
                    ... SVG Paths ...
                 </div> */}
            </div>

            <div className="flex flex-col sm:flex-row justify-between items-end sm:items-center mt-4">
              <div className="flex gap-6 text-xs font-medium">
                <div className="flex items-center gap-2 text-gray-600 dark:text-gray-400">
                  <span className="w-3 h-3 rounded bg-blue-500"></span>
                  Doctors
                </div>
                <div className="flex items-center gap-2 text-gray-600 dark:text-gray-400">
                  <span className="w-3 h-3 rounded bg-green-500"></span>
                  Patients
                </div>
              </div>
              <div className="text-right mt-4 sm:mt-0">
                <span className="text-3xl font-bold text-text-main-light dark:text-text-main-dark block">+12%</span>
                <span className="text-xs text-text-sub-light dark:text-text-sub-dark uppercase tracking-wider">Growth</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right Sidebar */}
        <div className="w-full xl:w-[400px] border-l border-gray-100 dark:border-gray-700 bg-white dark:bg-gray-800/50 p-6 md:p-8 flex flex-col gap-10">

          {/* Quick Navigation / Meetings Replacement */}
          <div>
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-lg font-bold text-text-main-light dark:text-text-main-dark">Quick Navigation</h3>
              {/* <button className="w-8 h-8 rounded-lg border border-gray-200 dark:border-gray-600 flex items-center justify-center hover:bg-gray-50 dark:hover:bg-gray-700 text-gray-600 dark:text-gray-300">
                <Calendar className="w-4 h-4" />
              </button> */}
            </div>
            <div className="space-y-6">

              <Link href="/doctors" className="block group cursor-pointer">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <h4 className="font-semibold text-text-main-light dark:text-text-main-dark text-sm">Doctor Management</h4>
                    <div className="flex items-center gap-2 mt-1">
                      <Users className="text-blue-500 w-3 h-3" />
                      <span className="text-xs text-text-sub-light dark:text-text-sub-dark">Staff & Verifications</span>
                    </div>
                  </div>
                  <ArrowUpRight className="text-gray-400 w-4 h-4 transform group-hover:translate-x-1 transition-transform" />
                </div>
                <div className="flex justify-between text-xs font-medium border-b border-gray-100 dark:border-gray-700 pb-4 group-last:border-0 group-last:pb-0">
                  <span className="text-gray-400 dark:text-gray-500">Status</span>
                  <span className="text-blue-600 font-bold">{stats.pendingDoctors > 0 ? `${stats.pendingDoctors} Pending` : 'All Clear'}</span>
                </div>
              </Link>

              <Link href="/hospitals" className="block group cursor-pointer">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <h4 className="font-semibold text-text-main-light dark:text-text-main-dark text-sm">Hospitals & Clinics</h4>
                    <div className="flex items-center gap-2 mt-1">
                      <Building2 className="text-indigo-500 w-3 h-3" />
                      <span className="text-xs text-text-sub-light dark:text-text-sub-dark">Facilities</span>
                    </div>
                  </div>
                  <ArrowUpRight className="text-gray-400 w-4 h-4 transform group-hover:translate-x-1 transition-transform" />
                </div>
                <div className="flex justify-between text-xs font-medium border-b border-gray-100 dark:border-gray-700 pb-4 group-last:border-0 group-last:pb-0">
                  <span className="text-gray-400 dark:text-gray-500">Registered</span>
                  <span className="text-text-main-light dark:text-text-main-dark">{stats.hospitals} Facilities</span>
                </div>
              </Link>

              <Link href="/patients" className="block group cursor-pointer">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <h4 className="font-semibold text-text-main-light dark:text-text-main-dark text-sm">Patient Directory</h4>
                    <div className="flex items-center gap-2 mt-1">
                      <Users className="text-green-500 w-3 h-3" />
                      <span className="text-xs text-text-sub-light dark:text-text-sub-dark">Users</span>
                    </div>
                  </div>
                  <ArrowUpRight className="text-gray-400 w-4 h-4 transform group-hover:translate-x-1 transition-transform" />
                </div>
                <div className="flex justify-between text-xs font-medium border-b border-gray-100 dark:border-gray-700 pb-4 group-last:border-0 group-last:pb-0">
                  <span className="text-gray-400 dark:text-gray-500">Total Users</span>
                  <span className="text-text-main-light dark:text-text-main-dark">{stats.patients}</span>
                </div>
              </Link>

              <Link href="/reports" className="block group cursor-pointer">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <h4 className="font-semibold text-text-main-light dark:text-text-main-dark text-sm">System Reports</h4>
                    <div className="flex items-center gap-2 mt-1">
                      <FileText className="text-purple-500 w-3 h-3" />
                      <span className="text-xs text-text-sub-light dark:text-text-sub-dark">Analytics</span>
                    </div>
                  </div>
                  <ArrowUpRight className="text-gray-400 w-4 h-4 transform group-hover:translate-x-1 transition-transform" />
                </div>
                <div className="flex justify-between text-xs font-medium pb-2">
                  <span className="text-gray-400 dark:text-gray-500">View</span>
                  <span className="text-text-main-light dark:text-text-main-dark">Logs</span>
                </div>
              </Link>

            </div>
          </div>

          {/* System Health / Developed Areas */}
          <div>
            <h3 className="text-lg font-bold text-text-main-light dark:text-text-main-dark mb-1">System Health</h3>
            <p className="text-xs text-text-sub-light dark:text-text-sub-dark mb-6">Database & API Status</p>
            <div className="space-y-5">

              <div className="flex items-center justify-between gap-4">
                <span className="text-sm font-medium text-text-main-light dark:text-text-main-dark w-24">Database</span>
                <div className="flex-1 h-2 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
                  <div className="h-full bg-green-500 w-[98%] rounded-full"></div>
                </div>
                <div className="flex items-center gap-2 w-12 justify-end">
                  <span className="text-xs font-semibold text-gray-500 dark:text-gray-400">98%</span>
                  <Activity className="text-green-500 w-3 h-3" />
                </div>
              </div>

              <div className="flex items-center justify-between gap-4">
                <span className="text-sm font-medium text-text-main-light dark:text-text-main-dark w-24">API Uptime</span>
                <div className="flex-1 h-2 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
                  <div className="h-full bg-blue-500 w-[99%] rounded-full"></div>
                </div>
                <div className="flex items-center gap-2 w-12 justify-end">
                  <span className="text-xs font-semibold text-gray-500 dark:text-gray-400">99%</span>
                  <Activity className="text-blue-500 w-3 h-3" />
                </div>
              </div>

              <div className="flex items-center justify-between gap-4">
                <span className="text-sm font-medium text-text-main-light dark:text-text-main-dark w-24">Storage</span>
                <div className="flex-1 h-2 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
                  <div className="h-full bg-orange-400 w-[45%] rounded-full"></div>
                </div>
                <div className="flex items-center gap-2 w-12 justify-end">
                  <span className="text-xs font-semibold text-gray-500 dark:text-gray-400">45%</span>
                  <ArrowDownCircle className="text-orange-400 w-3 h-3" />
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

